//
//  XCTPerformanceMetric+Extensions.swift
//  Algorithms-UnitTests
//
//  Created by Petro Korienev on 5/10/18.
//  Copyright © 2018 Sigma Software. All rights reserved.
//

import XCTest

public extension XCTPerformanceMetric {
    public static let userTime = XCTPerformanceMetric(rawValue: "com.apple.XCTPerformanceMetric_UserTime")
    public static let runTime = XCTPerformanceMetric(rawValue: "com.apple.XCTPerformanceMetric_RunTime")
    public static let systemTime = XCTPerformanceMetric(rawValue: "com.apple.XCTPerformanceMetric_SystemTime")
    public static let transientVMKB = XCTPerformanceMetric(rawValue: "com.apple.XCTPerformanceMetric_TransientVMAllocationsKilobytes")
    public static let temporaryHeapKB = XCTPerformanceMetric(rawValue: "com.apple.XCTPerformanceMetric_TemporaryHeapAllocationsKilobytes")
    public static let highWatermarkVM = XCTPerformanceMetric(rawValue: "com.apple.XCTPerformanceMetric_HighWaterMarkForVMAllocations")
    public static let totalHeapKB = XCTPerformanceMetric(rawValue: "com.apple.XCTPerformanceMetric_TotalHeapAllocationsKilobytes")
    public static let persistentVM = XCTPerformanceMetric(rawValue: "com.apple.XCTPerformanceMetric_PersistentVMAllocations")
    public static let persistentHeap = XCTPerformanceMetric(rawValue: "com.apple.XCTPerformanceMetric_PersistentHeapAllocations")
    public static let transientHeapKB = XCTPerformanceMetric(rawValue: "com.apple.XCTPerformanceMetric_TransientHeapAllocationsKilobytes")
    public static let persistentHeapNodes = XCTPerformanceMetric(rawValue: "com.apple.XCTPerformanceMetric_PersistentHeapAllocationsNodes")
    public static let highWatermarkHeap = XCTPerformanceMetric(rawValue: "com.apple.XCTPerformanceMetric_HighWaterMarkForHeapAllocations")
    public static let transientHeapNodes = XCTPerformanceMetric(rawValue: "com.apple.XCTPerformanceMetric_TransientHeapAllocationsNodes")
    
    public static let all: [XCTPerformanceMetric] = [.wallClockTime,
                                                     .userTime,
                                                     .runTime,
                                                     .systemTime,
                                                     .transientVMKB,
                                                     .temporaryHeapKB,
                                                     .highWatermarkVM,
                                                     .totalHeapKB,
                                                     .persistentVM,
                                                     .persistentHeap,
                                                     .transientHeapKB,
                                                     .persistentHeapNodes,
                                                     .highWatermarkHeap,
                                                     .transientHeapNodes]
}
