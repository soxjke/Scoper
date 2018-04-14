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
    public let memoryFootping: MemoryFootprint?
    public let diskUsage: DiskUsage?
    public let frameRate: FrameRate?
}

class RawResults {
    var runTime: [Double] = []
    var cpuTimeUser: [Double] = []
    var cpuTimeSystem: [Double] = []
    var cpuTimeIdle: [Double] = []
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
