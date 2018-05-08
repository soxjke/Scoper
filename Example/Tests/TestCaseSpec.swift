//
//  TestCaseSpec.swift
//  Scoper_Tests
//
//  Created by Petro Korienev on 5/8/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Quick
import Nimble
@testable import Scoper

class TestCaseSpec: QuickSpec {
    private struct Constants {
        static let helloWorldString = "Hello world"
        static let twentyTwo = 22
        static let doubleFive: Double = 5
        static let dispatchQueue = DispatchQueue(label: "TestCaseSpec")
        
        static let defaultTimeout: Double = 60
        static let defaultNumberOfRuns = 10
    }
    
    override func spec() {
        let worker: DefaultTestCase.Worker = { _, _ in }
        describe("builder") {
            it("should init with values from builder") {
                let workerCallSpy = CallSpy.makeCallSpy(f2: worker)
                let testCase = DefaultTestCase.Builder()
                    .name(Constants.helloWorldString)
                    .async()
                    .numberOfRuns(Constants.twentyTwo)
                    .timeout(Constants.doubleFive)
                    .worker(workerCallSpy.1)
                    .entryPointQueue(Constants.dispatchQueue)
                    .build()
                expect(testCase.variables.name) == Constants.helloWorldString
                expect(testCase.variables.async) == true
                expect(testCase.variables.numberOfRuns) == Constants.twentyTwo
                expect(testCase.variables.timeout).to(beCloseTo(Constants.doubleFive))
                expect(testCase.variables.entryPointQueue) == Constants.dispatchQueue
                testCase.variables.worker?(DefaultContext(), {})
                expect(workerCallSpy.0.callCount) == 1
            }
            it("should init with correct default name when not specified") {
                expect(UUID(uuidString: DefaultTestCase.Builder().build().variables.name)).toNot(beNil())
            }
            it("should init with default timeout when not specified") {
                expect(DefaultTestCase.Builder().build().variables.timeout).to(beCloseTo(Constants.defaultTimeout))
            }
            it("should init not async not specified") {
                expect(DefaultTestCase.Builder().build().variables.async) == false
            }
            it("should init with default number of runs when not specified") {
                expect(DefaultTestCase.Builder().build().variables.numberOfRuns) == Constants.defaultNumberOfRuns
            }
            it("should init with main queue when not specified") {
                expect(DefaultTestCase.Builder().build().variables.entryPointQueue) == DispatchQueue.main
            }
        }
    }
}
