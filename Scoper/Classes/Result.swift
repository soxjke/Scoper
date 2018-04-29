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
    
    public let memoryUsage: MemoryFootpintSlice
    public let peakMemoryUsage: MemoryFootpintSlice
}

public struct DiskUsage {
    public struct DiskIOCountSlice: StatisticsSlice {
        public static let UOM: String = "operations"
        
        public let minimum: UInt64
        public let maximum: UInt64
        public let median: UInt64
        public let mean: UInt64
        public let stdev: UInt64
    }
    public struct DiskIODataSlice: StatisticsSlice {
        public static let UOM: String = "KB"
        
        public let minimum: UInt64
        public let maximum: UInt64
        public let median: UInt64
        public let mean: UInt64
        public let stdev: UInt64
    }
    
    public let readCount: DiskIOCountSlice
    public let writeCount: DiskIOCountSlice
    public let readDataSize: DiskIODataSlice
    public let writeDataSize: DiskIODataSlice
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
    public let peakFrameRate: FrameRateSlice
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
    var memoryUsage: [UInt64] = []
    var peakMemoryUsage: [[UInt64]] = []
    var diskReadCount: [UInt64] = []
    var diskWriteCount: [UInt64] = []
    var diskReadDataSize: [UInt64] = []
    var diskWriteDataSize: [UInt64] = []
    var frameRate: [Double] = []
    var peakFrameRate: [[Double]] = []
    required init(numberOfRuns: Int) {
        runTime = .init(repeating: 0, count: numberOfRuns)
        cpuTimeUser = .init(repeating: 0, count: numberOfRuns)
        cpuTimeSystem = .init(repeating: 0, count: numberOfRuns)
        cpuTimeIdle = .init(repeating: 0, count: numberOfRuns)
        hostCpuTimeUser = .init(repeating: 0, count: numberOfRuns)
        hostCpuTimeSystem = .init(repeating: 0, count: numberOfRuns)
        hostCpuTimeIdle = .init(repeating: 0, count: numberOfRuns)
        memoryUsage = .init(repeating: 0, count: numberOfRuns)
        peakMemoryUsage = .init(repeating: [], count: numberOfRuns)
        diskReadCount = .init(repeating: 0, count: numberOfRuns)
        diskWriteCount = .init(repeating: 0, count: numberOfRuns)
        diskReadDataSize = .init(repeating: 0, count: numberOfRuns)
        diskWriteDataSize = .init(repeating: 0, count: numberOfRuns)
        frameRate = .init(repeating: 0, count: numberOfRuns)
        peakFrameRate = .init(repeating: [], count: numberOfRuns)
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
        let memoryUsageArray = endMeasurements.memoryUsage.diff(from: startMeasurements.memoryUsage)
        let peakMemoryUsageArray = endMeasurements.peakMemoryUsage.map { $0.maximum() ?? 0 }.diff(from: startMeasurements.peakMemoryUsage.map { $0.maximum() ?? 0 } )
        let diskReadCountArray = endMeasurements.diskReadCount.diff(from: startMeasurements.diskReadCount)
        let diskWriteCountArray = endMeasurements.diskWriteCount.diff(from: startMeasurements.diskWriteCount)
        let diskReadDataSizeArray = endMeasurements.diskReadDataSize.diff(from: startMeasurements.diskReadDataSize)
        let diskWriteDataSizeArray = endMeasurements.diskWriteDataSize.diff(from: startMeasurements.diskWriteDataSize)
        let frameRateArray = endMeasurements.frameRate.diff(from: startMeasurements.frameRate)
        let peakFrameRateArray = endMeasurements.peakFrameRate.map { $0.minimum() ?? 0 }.diff(from: startMeasurements.peakFrameRate.map { $0.minimum() ?? 0 } )
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
        memoryFootprint = MemoryFootprint(memoryUsage: MemoryFootprint.MemoryFootpintSlice(minimum: memoryUsageArray.minimum() ?? 0,
                                                                                           maximum: memoryUsageArray.maximum() ?? 0,
                                                                                           median: memoryUsageArray.median ?? 0,
                                                                                           mean: memoryUsageArray.mean,
                                                                                           stdev: memoryUsageArray.stdev),
                                          peakMemoryUsage: MemoryFootprint.MemoryFootpintSlice(minimum: peakMemoryUsageArray.minimum() ?? 0,
                                                                                               maximum: peakMemoryUsageArray.maximum() ?? 0,
                                                                                               median: peakMemoryUsageArray.median ?? 0,
                                                                                               mean: peakMemoryUsageArray.mean,
                                                                                               stdev: peakMemoryUsageArray.stdev))
        diskUsage = DiskUsage(readCount: DiskUsage.DiskIOCountSlice(minimum: diskReadCountArray.minimum() ?? 0,
                                                                    maximum: diskReadCountArray.maximum() ?? 0,
                                                                    median: diskReadCountArray.median ?? 0,
                                                                    mean: diskReadCountArray.mean,
                                                                    stdev: diskReadCountArray.stdev),
                              writeCount: DiskUsage.DiskIOCountSlice(minimum: diskWriteCountArray.minimum() ?? 0,
                                                                     maximum: diskWriteCountArray.maximum() ?? 0,
                                                                     median: diskWriteCountArray.median ?? 0,
                                                                     mean: diskWriteCountArray.mean,
                                                                     stdev: diskWriteCountArray.stdev),
                              readDataSize: DiskUsage.DiskIODataSlice(minimum: diskReadDataSizeArray.minimum() ?? 0,
                                                                      maximum: diskReadDataSizeArray.maximum() ?? 0,
                                                                      median: diskReadDataSizeArray.median ?? 0,
                                                                      mean: diskReadDataSizeArray.mean,
                                                                      stdev: diskReadDataSizeArray.stdev),
                              writeDataSize: DiskUsage.DiskIODataSlice(minimum: diskWriteDataSizeArray.minimum() ?? 0,
                                                                       maximum: diskWriteDataSizeArray.maximum() ?? 0,
                                                                       median: diskWriteDataSizeArray.median ?? 0,
                                                                       mean: diskWriteDataSizeArray.mean,
                                                                       stdev: diskWriteDataSizeArray.stdev))
        frameRate = FrameRate(frameRate: FrameRate.FrameRateSlice(minimum: frameRateArray.minimum() ?? 0,
                                                                    maximum: frameRateArray.maximum() ?? 0,
                                                                    median: frameRateArray.median ?? 0,
                                                                    mean: frameRateArray.mean,
                                                                    stdev: frameRateArray.stdev),
                              peakFrameRate: FrameRate.FrameRateSlice(minimum: peakFrameRateArray.minimum() ?? 0,
                                                                        maximum: peakFrameRateArray.maximum() ?? 0,
                                                                        median: peakFrameRateArray.median ?? 0,
                                                                        mean: peakFrameRateArray.mean,
                                                                        stdev: peakFrameRateArray.stdev))
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

extension Array where Element: Numeric {
    func diff(from: [Element]) -> [Element] {
        let minCount = Swift.min(count, from.count)
        return (0..<minCount).map { index -> Element in
            return self[index] - from[index]
        }
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
            let diff = element - meanValue
            return result + diff * diff
        }
        return UInt64(sqrt(Double(quadSum / UInt64(count))))
    }
}
