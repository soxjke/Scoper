//
//  ScopeSpec.swift
//  Scoper_Example
//
//  Created by Petro Korienev on 4/8/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Quick
import Nimble
@testable import Scoper

class ScopeSpec: QuickSpec {
    private struct Constants {
        static let helloWorldString = "Hello world"
    }
    
    override func spec() {
        let before: DefaultScope.Worker = { _ in }
        let beforeEach: DefaultScope.Worker = { _ in }
        let after: DefaultScope.Worker = { _ in }
        let afterEach: DefaultScope.Worker = { _ in }
        describe("builder") {
            it("should init with blocks from builder") {
                let beforeCallSpy = CallSpy.makeCallSpy(f1: before)
                let beforeEachCallSpy = CallSpy.makeCallSpy(f1: beforeEach)
                let afterCallSpy = CallSpy.makeCallSpy(f1: after)
                let afterEachCallSpy = CallSpy.makeCallSpy(f1: afterEach)
                let scope = DefaultScope.Builder()
                                .before(beforeCallSpy.1)
                                .beforeEach(beforeEachCallSpy.1)
                                .after(afterCallSpy.1)
                                .afterEach(afterEachCallSpy.1)
                                .build()
                scope.variables.before?(DefaultContext())
                scope.variables.beforeEach?(DefaultContext())
                scope.variables.after?(DefaultContext())
                scope.variables.afterEach?(DefaultContext())
                expect(beforeCallSpy.0.callCount) == 1
                expect(beforeEachCallSpy.0.callCount) == 1
                expect(afterCallSpy.0.callCount) == 1
                expect(afterEachCallSpy.0.callCount) == 1
            }
            it("should init with values from builder") {
                let scope = DefaultScope.Builder()
                                .name(Constants.helloWorldString)
                                .options(TestOptions.basic)
                                .build()
                expect(scope.variables.name) == Constants.helloWorldString
                expect(scope.variables.options) == TestOptions.basic
            }
            it("should init with test cases from builder") {
                let testCase1 = DefaultTestCase.Builder().build()
                let testCase2 = DefaultTestCase.Builder().build()
                let testCase3 = DefaultTestCase.Builder().build()
                let scope = DefaultScope.Builder()
                                .testCase(testCase1)
                                .testCase(testCase2)
                                .testCase(testCase3)
                                .build()
                expect(scope.variables.testCases).to(contain([testCase1, testCase2, testCase3]))
            }
            it("should init with test cases and nested scopes from builder") {
                let testCase1 = DefaultTestCase.Builder().build()
                let testCase2 = DefaultTestCase.Builder().build()
                let testCase3 = DefaultTestCase.Builder().build()
                let nestedScope = DefaultScope.Builder()
                                    .testCase(testCase1)
                                    .testCase(testCase2)
                                    .build()
                let scope = DefaultScope.Builder()
                    .testCase(testCase3)
                    .nestedScope(nestedScope)
                    .build()
                expect(scope.variables.testCases).to(contain([testCase3]))
                expect(scope.variables.scopes).to(contain([nestedScope]))
                expect(scope.variables.scopes.first?.variables.testCases).to(contain([testCase1, testCase2]))
            }
            it("should init with correct default name when not specified") {
                expect(UUID(uuidString: DefaultScope.Builder().build().variables.name)).toNot(beNil())
            }
            it("should init with basic options when not specified") {
                expect(DefaultScope.Builder().build().variables.options) == TestOptions.basic
            }
        }
    }
}
