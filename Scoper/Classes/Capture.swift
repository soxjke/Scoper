//
//  Capture.swift
//  Scoper
//
//  Created by Petro Korienev on 4/14/18.
//

import Darwin
#if (os(iOS) || os(tvOS))
    import UIKit
#else
    #if os(OSX)
        import AppKit
    #endif
#endif

protocol CaptureProtocol {
    func capture(_ results: RawResults, run: Int, options: TestOptions)
}

class Capture: CaptureProtocol {
    private struct Constants {
        static let targetFrameRate: Double = 120 // Consider iPad Pro with ProMotion feature
        static let macosTargetCaptureUpdateInterval: TimeInterval = 0.1
        static let frameRateInterval: TimeInterval = 1
        static let initialPeakMemory : UInt64 = 0
    }
    private class SystemInfo: NSObject {
#if (os(iOS) || os(tvOS))
        private(set) var displayLink: CADisplayLink!
#else
    #if os(OSX)
        private(set) var timer: Timer!
    #endif
#endif
        private(set) var sysInfoThread: Thread!
        private(set) var numberOfProcessors: Int!
        private(set) var processId: pid_t!
        
        private(set) var frameTimestamps: [Double] = []
        fileprivate var frameRate: Double {
            return Double(frameTimestamps.count - 1) / ((frameTimestamps.last ?? 0) - (frameTimestamps.first ?? 0))
        }
        fileprivate var lowestFrameRate: Double = Constants.targetFrameRate
        fileprivate var peakPhysicalMemory: UInt64 = Constants.initialPeakMemory
        fileprivate var peakResidentMemory: UInt64 = Constants.initialPeakMemory
        
        typealias proc_pid_rusage_type = @convention(c) (pid_t, Int32, UnsafeMutablePointer<rusage_info_current>) -> kern_return_t
        private(set) var proc_pid_rusage = unsafeBitCast(dlsym(UnsafeMutableRawPointer(bitPattern: -3), "proc_pid_rusage"),
                                                         to: proc_pid_rusage_type.self) // -3 for RTLD_SELF
        override init() {
            super.init()
            numberOfProcessors = ProcessInfo.processInfo.activeProcessorCount
            processId = ProcessInfo.processInfo.processIdentifier
#if (os(iOS) || os(tvOS))
            displayLink = CADisplayLink(target: self, selector: #selector(frame(link:)))
#endif
            sysInfoThread = Thread.init(target: self, selector: #selector(threadEntryPoint), object: nil)
            sysInfoThread.start()
        }
#if (os(iOS) || os(tvOS))
        @objc func frame(link: CADisplayLink) {
            frameTimestamps.append(link.timestamp)
            if link.timestamp - frameTimestamps.first! > 1 { frameTimestamps.removeFirst() }
            lowestFrameRate = Swift.min(frameRate, lowestFrameRate)
            captureMemory()
        }
#else
    #if os(OSX)
        @objc func tick(timer: Timer) {
            captureMemory()
        }
    #endif
#endif
        private func captureMemory() {
            var info = rusage_info_current()
            guard KERN_SUCCESS == SystemInfo.shared.proc_pid_rusage(ProcessInfo.processInfo.processIdentifier, RUSAGE_INFO_CURRENT, &info) else {
                return
            }
            if info.ri_phys_footprint > peakPhysicalMemory { peakPhysicalMemory = info.ri_phys_footprint }
            if info.ri_resident_size > peakResidentMemory { peakResidentMemory = info.ri_resident_size }
        }
        fileprivate func captureLowestFrameRate() -> Double {
            defer { lowestFrameRate = Constants.targetFrameRate }
            return lowestFrameRate
        }
        fileprivate func captureMemoryPeaks() -> (physical: UInt64, resident: UInt64) {
            defer {
                peakPhysicalMemory = Constants.initialPeakMemory
                peakResidentMemory = Constants.initialPeakMemory
            }
            return (physical: peakPhysicalMemory, resident: peakResidentMemory)
        }
        @objc func threadEntryPoint() {
#if (os(iOS) || os(tvOS))
            displayLink.add(to: .current,
                            forMode: .defaultRunLoopMode)
#else
    #if os(OSX)
        timer = Timer.scheduledTimer(timeInterval: Constants.macosTargetCaptureUpdateInterval,
                                     target: self,
                                     selector: #selector(tick(timer:)),
                                     userInfo: nil,
                                     repeats: true)
    #endif
#endif
            RunLoop.current.run()
        }
        
        static let shared = SystemInfo()
    }
    
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
        var info = rusage_info_current()
        guard KERN_SUCCESS == SystemInfo.shared.proc_pid_rusage(ProcessInfo.processInfo.processIdentifier, RUSAGE_INFO_CURRENT, &info) else {
            return
        }
        let totalIdleTimeUnadjusted: Double = Double(DispatchTime.now().uptimeNanoseconds) / Double(NSEC_PER_SEC);
        let totalSystemTime: Double = Double(info.ri_system_time) / Double(NSEC_PER_SEC)
        let totalUserTime: Double = Double(info.ri_user_time) / Double(NSEC_PER_SEC)
        results.cpuTimeSystem[run] = totalSystemTime / Double(SystemInfo.shared.numberOfProcessors)
        results.cpuTimeUser[run] = totalUserTime / Double(SystemInfo.shared.numberOfProcessors)
        results.cpuTimeIdle[run] = (totalIdleTimeUnadjusted - (totalSystemTime + totalUserTime) / Double(SystemInfo.shared.numberOfProcessors))
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

        results.hostCpuTimeSystem[run] = Double(totalSystemTime) / Double(SystemInfo.shared.numberOfProcessors)
        results.hostCpuTimeUser[run] = Double(totalUserTime) / Double(SystemInfo.shared.numberOfProcessors)
        results.hostCpuTimeIdle[run] = Double(totalIdleTime) / Double(SystemInfo.shared.numberOfProcessors)
    }
    private func captureMemoryFootprint(_ results: RawResults, run: Int) {
        var info = rusage_info_current()
        guard KERN_SUCCESS == SystemInfo.shared.proc_pid_rusage(ProcessInfo.processInfo.processIdentifier, RUSAGE_INFO_CURRENT, &info) else {
            return
        }
        results.memoryUsagePhys[run] = info.ri_phys_footprint
        results.memoryUsageResident[run] = info.ri_resident_size
        let peak = SystemInfo.shared.captureMemoryPeaks()
        results.memoryUsagePhysMax[run] = peak.physical
        results.memoryUsageResidentMax[run] = peak.resident
    }
    private func captureDiskUsage(_ results: RawResults, run: Int) {
        var info = rusage_info_current()
        guard KERN_SUCCESS == SystemInfo.shared.proc_pid_rusage(ProcessInfo.processInfo.processIdentifier, RUSAGE_INFO_CURRENT, &info) else {
            return
        }
        results.diskReadBytes[run] = info.ri_diskio_bytesread
        results.diskWrittenBytes[run] = info.ri_diskio_byteswritten
    }
    private func captureFrameRate(_ results: RawResults, run: Int) {
        results.frameRate[run] = SystemInfo.shared.frameRate
        results.lowestFrameRate[run] = SystemInfo.shared.captureLowestFrameRate()
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
