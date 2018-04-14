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
        static let helloWorldString2 = "Hello world2"
        static let stringKey1 = "stringKey1"
        static let stringKey2 = "stringKey2"
        static let oneNumber = 1
    }
    
    override func spec() {
        let before: DefaultScope.Worker = { _ in }
        let beforeEach: DefaultScope.Worker = { _ in }
        let after: DefaultScope.Worker = { _ in }
        let afterEach: DefaultScope.Worker = { _ in }
        let context = DefaultContext()
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
                scope.variables.before?(context)
                scope.variables.beforeEach?(context)
                scope.variables.after?(context)
                scope.variables.afterEach?(context)
                expect(beforeCallSpy.0.callCount) == 1
                expect(beforeEachCallSpy.0.callCount) == 1
                expect(afterCallSpy.0.callCount) == 1
                expect(afterEachCallSpy.0.callCount) == 1
            }
        }
    }
}

