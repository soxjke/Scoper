//
//  Result.swift
//  Scoper
//
//  Created by Petro Korienev on 4/9/18.
//

public protocol StatisticsSlice {
    associatedtype ValueType
    static var UOM: String { get }
    var minimum: ValueType { get }
    var maximum: ValueType { get }
    var median: ValueType { get }
    var mean: ValueType { get }
    var stdev: ValueType { get }
}

public struct RunTime: StatisticsSlice {
    public static let UOM: String = "s"
    
    public let minimum: Double
    public let maximum: Double
    public let median: Double
    public let mean: Double
    public let stdev: Double
}

public struct CPUTime {
    public struct CPUTimeSlice: StatisticsSlice {
        public static let UOM: String = "s"
        
        public let minimum: Double
        public let maximum: Double
        public let median: Double
        public let mean: Double
        public let stdev: Double
    }
    
    public let userTime: CPUTimeSlice
    public let systemTime: CPUTimeSlice
    public let idleTime: CPUTimeSlice
}

public struct MemoryFootprint {
    public struct MemoryFootpintSlice: StatisticsSlice {
        public static let UOM: String = "KB"
        
        public let minimum: UInt64
        public let maximum: UInt64
        public let median: UInt64
        public let mean: UInt64
        public let stdev: UInt64
    }
    
    public let memoryUsagePhys: MemoryFootpintSlice
    public let memoryUsagePhysMax: MemoryFootpintSlice
    public let memoryUsageResident: MemoryFootpintSlice
}

public struct DiskUsage {
    public struct DiskIODataSlice: StatisticsSlice {
        public static let UOM: String = "KB"
        
        public let minimum: UInt64
        public let maximum: UInt64
        public let median: UInt64
        public let mean: UInt64
        public let stdev: UInt64
    }
    
    public let diskReadBytes: DiskIODataSlice
    public let diskWrittenBytes: DiskIODataSlice
}

public struct FrameRate {
    public struct FrameRateSlice: StatisticsSlice {
        public static let UOM: String = "fps"
        
        public let minimum: Double
        public let maximum: Double
        public let median: Double
        public let mean: Double
        public let stdev: Double
    }
    
    public let frameRate: FrameRateSlice
    public let lowestFrameRate: FrameRateSlice
}

public struct Result {
    public let runTime: RunTime?
    public let cpuTime: CPUTime?
    public let hostCpuTime: CPUTime?
    public let memoryFootprint: MemoryFootprint?
    public let diskUsage: DiskUsage?
    public let frameRate: FrameRate?
}

class RawResults {
    var runTime: [Double] = []
    var cpuTimeUser: [Double] = []
    var cpuTimeSystem: [Double] = []
    var cpuTimeIdle: [Double] = []
    var hostCpuTimeUser: [Double] = []
    var hostCpuTimeSystem: [Double] = []
    var hostCpuTimeIdle: [Double] = []
    var memoryUsagePhys: [UInt64] = []
    var memoryUsagePhysMax: [UInt64] = []
    var memoryUsageResident: [UInt64] = []
    var diskReadBytes: [UInt64] = []
    var diskWrittenBytes: [UInt64] = []
    var frameRate: [Double] = []
    var lowestFrameRate: [Double] = []
    required init(numberOfRuns: Int) {
        runTime = .init(repeating: 0, count: numberOfRuns)
        cpuTimeUser = .init(repeating: 0, count: numberOfRuns)
        cpuTimeSystem = .init(repeating: 0, count: numberOfRuns)
        cpuTimeIdle = .init(repeating: 0, count: numberOfRuns)
        hostCpuTimeUser = .init(repeating: 0, count: numberOfRuns)
        hostCpuTimeSystem = .init(repeating: 0, count: numberOfRuns)
        hostCpuTimeIdle = .init(repeating: 0, count: numberOfRuns)
        memoryUsagePhys = .init(repeating: 0, count: numberOfRuns)
        memoryUsagePhysMax = .init(repeating: 0, count: numberOfRuns)
        memoryUsageResident = .init(repeating: 0, count: numberOfRuns)
        diskReadBytes = .init(repeating: 0, count: numberOfRuns)
        diskWrittenBytes = .init(repeating: 0, count: numberOfRuns)
        frameRate = .init(repeating: 0, count: numberOfRuns)
        lowestFrameRate = .init(repeating: 0, count: numberOfRuns)
    }
}

extension Result {
    init(startMeasurements: RawResults, endMeasurements: RawResults) {
        let runTimeArray = endMeasurements.runTime.diff(from: startMeasurements.runTime)
        let cpuTimeUserArray = endMeasurements.cpuTimeUser.diff(from: startMeasurements.cpuTimeUser)
        let cpuTimeSystemArray = endMeasurements.cpuTimeSystem.diff(from: startMeasurements.cpuTimeSystem)
        let cpuTimeIdleArray = endMeasurements.cpuTimeIdle.diff(from: startMeasurements.cpuTimeIdle)
        let hostCpuTimeUserArray = endMeasurements.hostCpuTimeUser.diff(from: startMeasurements.hostCpuTimeUser)
        let hostCpuTimeSystemArray = endMeasurements.hostCpuTimeSystem.diff(from: startMeasurements.hostCpuTimeSystem)
        let hostCpuTimeIdleArray = endMeasurements.hostCpuTimeIdle.diff(from: startMeasurements.hostCpuTimeIdle)
        let memoryUsagePhysArray = endMeasurements.memoryUsagePhys.diff(from: startMeasurements.memoryUsagePhys)
        /*
         In the next line we do intentional subtraction from memoryUsagePhys and not memoryUsagePhysMax, it's not a typo
         */
        let memoryUsagePhysMaxArray = endMeasurements.memoryUsagePhysMax.diff(from: startMeasurements.memoryUsagePhys)
        let memoryUsageResidentArray = endMeasurements.memoryUsageResident.diff(from: startMeasurements.memoryUsageResident)
        let diskReadBytesArray = endMeasurements.diskReadBytes.diff(from: startMeasurements.diskReadBytes)
        let diskWrittenBytesArray = endMeasurements.diskWrittenBytes.diff(from: startMeasurements.diskWrittenBytes)
        /*
         Frame rate is not diffable entity
         */
        let frameRateArray = endMeasurements.frameRate
        let lowestFrameRateArray = endMeasurements.lowestFrameRate
        
        runTime = RunTime(minimum: runTimeArray.minimum() ?? 0,
                          maximum: runTimeArray.maximum() ?? 0,
                          median: runTimeArray.median ?? 0,
                          mean: runTimeArray.mean,
                          stdev: runTimeArray.stdev)
        cpuTime = CPUTime(userTime: CPUTime.CPUTimeSlice(minimum: cpuTimeUserArray.minimum() ?? 0,
                                                         maximum: cpuTimeUserArray.maximum() ?? 0,
                                                         median: cpuTimeUserArray.median ?? 0,
                                                         mean: cpuTimeUserArray.mean,
                                                         stdev: cpuTimeUserArray.stdev),
                          systemTime: CPUTime.CPUTimeSlice(minimum: cpuTimeSystemArray.minimum() ?? 0,
                                                           maximum: cpuTimeSystemArray.maximum() ?? 0,
                                                           median: cpuTimeSystemArray.median ?? 0,
                                                           mean: cpuTimeSystemArray.mean,
                                                           stdev: cpuTimeSystemArray.stdev),
                          idleTime: CPUTime.CPUTimeSlice(minimum: cpuTimeIdleArray.minimum() ?? 0,
                                                         maximum: cpuTimeIdleArray.maximum() ?? 0,
                                                         median: cpuTimeIdleArray.median ?? 0,
                                                         mean: cpuTimeIdleArray.mean,
                                                         stdev: cpuTimeIdleArray.stdev))
        hostCpuTime = CPUTime(userTime: CPUTime.CPUTimeSlice(minimum: hostCpuTimeUserArray.minimum() ?? 0,
                                                             maximum: hostCpuTimeUserArray.maximum() ?? 0,
                                                             median: hostCpuTimeUserArray.median ?? 0,
                                                             mean: hostCpuTimeUserArray.mean,
                                                             stdev: hostCpuTimeUserArray.stdev),
                              systemTime: CPUTime.CPUTimeSlice(minimum: hostCpuTimeSystemArray.minimum() ?? 0,
                                                               maximum: hostCpuTimeSystemArray.maximum() ?? 0,
                                                               median: hostCpuTimeSystemArray.median ?? 0,
                                                               mean: hostCpuTimeSystemArray.mean,
                                                               stdev: hostCpuTimeSystemArray.stdev),
                              idleTime: CPUTime.CPUTimeSlice(minimum: hostCpuTimeIdleArray.minimum() ?? 0,
                                                             maximum: hostCpuTimeIdleArray.maximum() ?? 0,
                                                             median: hostCpuTimeIdleArray.median ?? 0,
                                                             mean: hostCpuTimeIdleArray.mean,
                                                             stdev: hostCpuTimeIdleArray.stdev))
        memoryFootprint = MemoryFootprint(memoryUsagePhys: MemoryFootprint.MemoryFootpintSlice(minimum: memoryUsagePhysArray.minimum() ?? 0,
                                                                                           maximum: memoryUsagePhysArray.maximum() ?? 0,
                                                                                           median: memoryUsagePhysArray.median ?? 0,
                                                                                           mean: memoryUsagePhysArray.mean,
                                                                                           stdev: memoryUsagePhysArray.stdev),
                                          memoryUsagePhysMax: MemoryFootprint.MemoryFootpintSlice(minimum: memoryUsagePhysMaxArray.minimum() ?? 0,
                                                                                               maximum: memoryUsagePhysMaxArray.maximum() ?? 0,
                                                                                               median: memoryUsagePhysMaxArray.median ?? 0,
                                                                                               mean: memoryUsagePhysMaxArray.mean,
                                                                                               stdev: memoryUsagePhysMaxArray.stdev),
                                          memoryUsageResident: MemoryFootprint.MemoryFootpintSlice(minimum: memoryUsageResidentArray.minimum() ?? 0,
                                                                                               maximum: memoryUsageResidentArray.maximum() ?? 0,
                                                                                               median: memoryUsageResidentArray.median ?? 0,
                                                                                               mean: memoryUsageResidentArray.mean,
                                                                                               stdev: memoryUsageResidentArray.stdev))
        diskUsage = DiskUsage(diskReadBytes: DiskUsage.DiskIODataSlice(minimum: diskReadBytesArray.minimum() ?? 0,
                                                                      maximum: diskReadBytesArray.maximum() ?? 0,
                                                                      median: diskReadBytesArray.median ?? 0,
                                                                      mean: diskReadBytesArray.mean,
                                                                      stdev: diskReadBytesArray.stdev),
                              diskWrittenBytes: DiskUsage.DiskIODataSlice(minimum: diskWrittenBytesArray.minimum() ?? 0,
                                                                       maximum: diskWrittenBytesArray.maximum() ?? 0,
                                                                       median: diskWrittenBytesArray.median ?? 0,
                                                                       mean: diskWrittenBytesArray.mean,
                                                                       stdev: diskWrittenBytesArray.stdev))
        frameRate = FrameRate(frameRate: FrameRate.FrameRateSlice(minimum: frameRateArray.minimum() ?? 0,
                                                                    maximum: frameRateArray.maximum() ?? 0,
                                                                    median: frameRateArray.median ?? 0,
                                                                    mean: frameRateArray.mean,
                                                                    stdev: frameRateArray.stdev),
                              lowestFrameRate: FrameRate.FrameRateSlice(minimum: lowestFrameRateArray.minimum() ?? 0,
                                                                        maximum: lowestFrameRateArray.maximum() ?? 0,
                                                                        median: lowestFrameRateArray.median ?? 0,
                                                                        mean: lowestFrameRateArray.mean,
                                                                        stdev: lowestFrameRateArray.stdev))
    }
}

extension Array where Element: Comparable {
    func maximum() -> Element? {
        return self.max(by: <)
    }
    func minimum() -> Element? {
        return self.min(by: <)
    }
}

extension Array where Element: Numeric & Comparable {
    func diff(from: [Element], isSigned: Bool = false) -> [Element] {
        let minCount = Swift.min(count, from.count)
        return (0..<minCount).map { index -> Element in
            if !isSigned && self[index] < from[index] { return 0 }
            return self[index] - from[index]
        }
    }
}

extension Array where Element: SignedNumeric & Comparable {
    func diff(from: [Element]) -> [Element] {
        return diff(from: from, isSigned: true)
    }
}

extension Array {
    var median: Element? {
        return count > 0 ? self[count / 2] : nil
    }
}

extension Array where Element == Double {
    var mean: Element {
        return reduce(0, +) / Double(count)
    }
    var stdev: Element {
        let meanValue = mean
        let quadSum = reduce(0) { result, element -> Element in
            let diff = element - meanValue
            return result + diff * diff
        }
        return sqrt(quadSum / Double(count))
    }
}

extension Array where Element == UInt64 {
    var mean: Element {
        return reduce(0, +) / UInt64(count)
    }
    var stdev: Element {
        let meanValue = mean
        let quadSum = reduce(0) { result, element -> Element in
            let diff = (element < meanValue) ? (meanValue - element) : (element - meanValue)
            return result + diff * diff
        }
        return UInt64(sqrt(Double(quadSum / UInt64(count))))
    }
}
