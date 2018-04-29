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
    private class SystemInfo {
        private(set) var numberOfProcessors: Int = 1
        init() {
            var processorInfo: processor_info_array_t?
            var processorMsgCount: mach_msg_type_number_t = 0
            var processorCount: natural_t = 0
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
            numberOfProcessors = Int(processorCount)
        }
    }
    private let systemInfo = SystemInfo()
    
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
        
        results.cpuTimeSystem[run] = totalSystemTime / Double(systemInfo.numberOfProcessors)
        results.cpuTimeUser[run] = totalUserTime / Double(systemInfo.numberOfProcessors)
        results.cpuTimeIdle[run] = (totalIdleTimeUnadjusted - (totalSystemTime + totalUserTime)) / Double(systemInfo.numberOfProcessors)
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

        results.hostCpuTimeSystem[run] = Double(totalSystemTime) / Double(systemInfo.numberOfProcessors)
        results.hostCpuTimeUser[run] = Double(totalUserTime) / Double(systemInfo.numberOfProcessors)
        results.hostCpuTimeIdle[run] = Double(totalIdleTime) / Double(systemInfo.numberOfProcessors)
    }
    private func captureMemoryFootprint(_ results: RawResults, run: Int) {
        var kr: kern_return_t
        var taskInfoCount = mach_msg_type_number_t(TASK_INFO_MAX)
        
        taskInfoCount = mach_msg_type_number_t(TASK_INFO_MAX)
        var tInfo = [integer_t](repeating: 0, count: Int(taskInfoCount))
        
        kr = task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), &tInfo, &taskInfoCount)
        guard kr == KERN_SUCCESS else { return }
        defer {
            vm_deallocate(mach_host_self(), vm_address_t(UnsafePointer(tInfo).pointee), vm_size_t(taskInfoCount))
        }
        let taskVmInfo = task_vm_info(taskInfo: tInfo)
        print(taskVmInfo)
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

fileprivate extension mach_task_basic_info {
    init(taskInfo: [integer_t]) {
        let taskInfo64 = unsafeBitCast(taskInfo, to: [mach_vm_size_t].self)
        self.init(virtual_size: taskInfo64[0],
                  resident_size: taskInfo64[1],
                  resident_size_max: taskInfo64[2],
                  user_time: time_value_t(seconds: taskInfo[6], microseconds: taskInfo[7]),
                  system_time: time_value_t(seconds: taskInfo[8], microseconds: taskInfo[9]),
                  policy: taskInfo[10],
                  suspend_count: taskInfo[11])
    }
}

fileprivate extension task_vm_info {
    init(taskInfo: [integer_t]) {
        let taskInfo64 = unsafeBitCast(taskInfo, to: [mach_vm_size_t].self)
        self.init(virtual_size: taskInfo64[0],
                  region_count: taskInfo[2],
                  page_size: taskInfo[3],
                  resident_size: taskInfo64[2],
                  resident_size_peak: taskInfo64[3],
                  device: taskInfo64[4],
                  device_peak: taskInfo64[5],
                  internal: taskInfo64[6],
                  internal_peak: taskInfo64[7],
                  external: taskInfo64[8],
                  external_peak: taskInfo64[9],
                  reusable: taskInfo64[10],
                  reusable_peak: taskInfo64[11],
                  purgeable_volatile_pmap: taskInfo64[12],
                  purgeable_volatile_resident: taskInfo64[13],
                  purgeable_volatile_virtual: taskInfo64[14],
                  compressed: taskInfo64[15],
                  compressed_peak: taskInfo64[16],
                  compressed_lifetime: taskInfo64[17],
                  phys_footprint: taskInfo64[18],
                  min_address: taskInfo64[19],
                  max_address: taskInfo64[20])
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
