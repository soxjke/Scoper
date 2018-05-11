//
//  TestRunnerSpec.swift
//  Scoper_Tests
//
//  Created by Petro Korienev on 5/9/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import Scoper

class TestRunnerSpec: QuickSpec {
    override func spec() {
        let scope1 = DefaultScope.Builder().options([]).testCase( { _, _ in }).build()
        let scope2 = DefaultScope.Builder().options([]).testCase( { _, _ in }).build()
        it("should call completion after executing scope") {
            let completion: TestRunner.Completion = { _ in }
            let callSpy = CallSpy.makeCallSpy(f1: completion )
            TestRunner.shared.schedule(scope1, completion: callSpy.1 )
            expect(callSpy.0.callCount).toEventually(equal(1), timeout: 1)
        }
        it("should schedule two scopes one by one") {
            let completion: TestRunner.Completion = { _ in }
            let callSpy = CallSpy.makeCallSpy(f1: completion )
            TestRunner.shared.schedule(scope1, completion: callSpy.1 )
            TestRunner.shared.schedule(scope2, completion: callSpy.1 )
            expect(callSpy.0.callCount).toEventually(equal(2), timeout: 2)
        }
        it("should schedule two scopes one by one") {
            var first: Bool = true
            let completion: TestRunner.Completion = { _ in }
            let callSpy = CallSpy.makeCallSpy(f1: completion )
            let completion2: TestRunner.Completion = { _ in
                if first {
                    first = false
                    TestRunner.shared.schedule(scope2, completion: callSpy.1 )
                }
            }
            let callSpy2 = CallSpy.makeCallSpy(f1: completion2 )
            TestRunner.shared.schedule(scope1, completion: callSpy2.1 )
            expect(callSpy.0.callCount).toEventually(equal(1), timeout: 2)
            expect(callSpy2.0.callCount).toEventually(equal(1), timeout: 2)
        }
    }
}
