//
//  TestOptionsSpec.swift
//  Scoper_Tests
//
//  Created by Petro Korienev on 5/9/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Quick
import Nimble
@testable import Scoper

class TestOptionsSpec: QuickSpec {
    override func spec() {
        it("should contain all options in complete") {
            let memberwiseComplete: TestOptions = [.runTime, .cpuTime, .hostCpuTime, .memoryFootprint, .diskUsage, .frameRate, .logProgress, .logResults]
            expect(TestOptions.complete.intersection(memberwiseComplete)) == memberwiseComplete
        }
        it("should contain runTime, logProgress, logResults options in basic") {
            let memberwiseBasic: TestOptions = [.runTime, .logProgress, .logResults]
            expect(TestOptions.basic) == memberwiseBasic
        }
    }
}
