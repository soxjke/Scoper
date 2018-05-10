//
//  Algorithms_UnitTests.swift
//  Algorithms-UnitTests
//
//  Created by Petro Korienev on 5/10/18.
//  Copyright © 2018 Sigma Software. All rights reserved.
//

import XCTest

class Algorithms_UnitTests: XCTestCase {
    
    let source: [Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9]
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceFunctional() {
        // This is an example of a performance test case.
        self.measure {
            let _ = source.permutationsOverMutationsFunctionalOptimized4()
        }
    }
    
    func testPerformanceNonFunctional() {
        self.measure {
            let _ = source.permutationsOverMutations()
        }
    }
    
    func testPerformanceConcurrent() {
        self.measure {
            let _ = source.permutationsConcurrent(concurrentThreads: 4)
        }
    }
    
    func testPerformanceConcurrentUnsafe() {
        self.measure {
            let _ = source.permutationsConcurrentUnsafePointer(concurrentThreads: 4)
        }
    }
    
    override class var defaultPerformanceMetrics: [XCTPerformanceMetric] {
        return XCTPerformanceMetric.all
    }
}
