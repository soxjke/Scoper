//
//  TestUtils.swift
//  Scoper_Tests
//
//  Created by Petro Korienev on 5/8/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
@testable import Scoper

extension TestCase: Equatable {
    public static func ==(lhs: TestCase, rhs: TestCase) -> Bool {
        return unsafeBitCast(lhs, to: UnsafeRawPointer.self) == unsafeBitCast(rhs, to: UnsafeRawPointer.self)
    }
}

extension Scope: Equatable {
    public static func ==(lhs: Scope, rhs: Scope) -> Bool {
        return unsafeBitCast(lhs, to: UnsafeRawPointer.self) == unsafeBitCast(rhs, to: UnsafeRawPointer.self)
    }
}
