//
//  TestOptions.swift
//  Scoper
//
//  Created by Petro Korienev on 4/8/18.
//

public struct TestOptions: OptionSet {
    public let rawValue: Int64
    public init(rawValue: Int64) { self.rawValue = rawValue}
    
    public static let runTime = TestOptions(rawValue: 1 << 0)
    public static let cpuTime = TestOptions(rawValue: 1 << 1)
    public static let hostCpuTime = TestOptions(rawValue: 1 << 2)
    public static let memoryFootprint = TestOptions(rawValue: 1 << 3)
    public static let diskUsage = TestOptions(rawValue: 1 << 4)
    public static let frameRate = TestOptions(rawValue: 1 << 5)
    
    public static let logResults = TestOptions(rawValue: 1 << 16)
    public static let logProgress = TestOptions(rawValue: 1 << 17)
    public static let detailedStats = TestOptions(rawValue: 1 << 18)
    
    public static let complete = TestOptions(rawValue: Int64.max)
    public static let basic: TestOptions = [.runTime, .logResults, .logProgress]
}
