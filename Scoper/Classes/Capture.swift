//
//  Capture.swift
//  Scoper
//
//  Created by Petro Korienev on 4/14/18.
//

import Darwin.Mach

protocol CaptureProtocol {
    func capture(_ results: RawResults, run: Int, options: TestOptions)
}

class Capture: CaptureProtocol {
    func capture(_ results: RawResults, run: Int, options: TestOptions) {
        if options.contains(.runTime) { captureRunTime(results, run: run) }
        if options.contains(.cpuTime) { captureCpuTime(results, run: run) }
        if options.contains(.hostCpuTime) { captureHostCpuTime(results, run: run) }
        if options.contains(.memoryFootprint) { captureMemoryFootprint(results, run: run) }
        if options.contains(.diskUsage) { captureDiskUsage(results, run: run) }
        if options.contains(.frameRate) { captureFrameRate(results, run: run) }
    }
    private func captureRunTime(_ results: RawResults, run: Int) {
        results.runTime[run] = Double(DispatchTime.now().uptimeNanoseconds) / Double(NSEC_PER_SEC)
    }
    private func captureCpuTime(_ results: RawResults, run: Int) {
        var err: kern_return_t
        var threadList: thread_act_array_t? = UnsafeMutablePointer(mutating: [thread_act_t]())
        var threadCount: mach_msg_type_number_t = 0
        defer {
            if let threadList = threadList {
                vm_deallocate(mach_task_self_, vm_address_t(UnsafePointer(threadList).pointee), vm_size_t(threadCount))
            }
        }
        
        err = task_threads(mach_task_self_, &threadList, &threadCount)
        guard err == KERN_SUCCESS else { return }

        var totalSystemTime: Double = 0
        var totalUserTime: Double = 0
        let totalIdleTimeUnadjusted: Double = Double(DispatchTime.now().uptimeNanoseconds) / Double(NSEC_PER_SEC);

        if let threadList = threadList {
            (0..<threadCount).map { Int($0) } .forEach { thread in
                var threadInfoCount = mach_msg_type_number_t(THREAD_INFO_MAX)
                var threadInfo = [integer_t](repeating: 0, count: Int(threadInfoCount))
                err = thread_info(threadList[thread], thread_flavor_t(THREAD_BASIC_INFO), &threadInfo, &threadInfoCount)
                guard err == KERN_SUCCESS else { return }
                
                let threadBasicInfo = thread_basic_info(threadInfo: threadInfo)
                totalSystemTime += threadBasicInfo.system_time.doubleValue
                totalUserTime += threadBasicInfo.user_time.doubleValue
            }
        }
        
        results.cpuTimeSystem[run] = totalSystemTime
        results.cpuTimeUser[run] = totalUserTime
        results.cpuTimeIdle[run] = totalIdleTimeUnadjusted - (totalSystemTime + totalUserTime)
    }
    
    private func captureHostCpuTime(_ results: RawResults, run: Int) {
        var processorInfo: processor_info_array_t?
        var processorMsgCount: mach_msg_type_number_t = 0
        var processorCount: natural_t = 0
        
        var totalSystemTime: Double = 0
        var totalUserTime: Double = 0
        var totalIdleTime: Double = 0;
        
        let err = host_processor_info(mach_host_self(),
                                      PROCESSOR_CPU_LOAD_INFO,
                                      &processorCount,
                                      &processorInfo,
                                      &processorMsgCount)
        guard err == KERN_SUCCESS else { return }
        defer {
            if let processorInfo = processorInfo {
                vm_deallocate(mach_host_self(), vm_address_t(UnsafePointer(processorInfo).pointee), vm_size_t(processorMsgCount))
            }
        }
        
        let cpuLoad: processor_cpu_load_info_t = unsafeBitCast(processorInfo, to: processor_cpu_load_info_t.self)
        
        (0..<processorCount).map { Int($0)} .forEach { processor in
            totalSystemTime += cpuLoad[processor].systemTime
            totalUserTime += cpuLoad[processor].userTime
            totalIdleTime += cpuLoad[processor].idleTime
        }

        results.hostCpuTimeSystem[run] = Double(totalSystemTime) / Double(processorCount)
        results.hostCpuTimeUser[run] = Double(totalUserTime) / Double(processorCount)
        results.hostCpuTimeIdle[run] = Double(totalIdleTime) / Double(processorCount)
    }
    private func captureMemoryFootprint(_ results: RawResults, run: Int) {
        
    }
    private func captureDiskUsage(_ results: RawResults, run: Int) {
        
    }
    private func captureFrameRate(_ results: RawResults, run: Int) {
        
    }
}

fileprivate extension thread_basic_info {
    init(threadInfo: [integer_t]) {
        self.init(user_time: time_value_t(seconds: threadInfo[0], microseconds: threadInfo[1]),
                  system_time: time_value_t(seconds: threadInfo[2], microseconds: threadInfo[3]),
                  cpu_usage: threadInfo[4],
                  policy: threadInfo[5],
                  run_state: threadInfo[6],
                  flags: threadInfo[7],
                  suspend_count: threadInfo[8],
                  sleep_time: threadInfo[9])
    }
}

fileprivate extension time_value {
    var doubleValue: Double {
        return Double(seconds) + Double(microseconds) / Double(USEC_PER_SEC)
    }
}

fileprivate extension processor_cpu_load_info {
    private struct Constants {
        static let TICKS_PER_SEC: Double = 100 /* cpu_load_info ticks per second */
    }
    var cpuTicksArray: [UInt32] {
        return [cpu_ticks.0, cpu_ticks.1, cpu_ticks.2, cpu_ticks.3]
    }
    var userTime: Double {
        return Double(cpuTicksArray[Int(CPU_STATE_USER)] + cpuTicksArray[Int(CPU_STATE_NICE)]) / Constants.TICKS_PER_SEC
    }
    var systemTime: Double {
        return Double(cpuTicksArray[Int(CPU_STATE_SYSTEM)]) / Constants.TICKS_PER_SEC
    }
    var idleTime: Double {
        return Double(cpuTicksArray[Int(CPU_STATE_IDLE)]) / Constants.TICKS_PER_SEC
    }
}
