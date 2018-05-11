//
//  ContextSpec.swift
//  Scoper_Tests
//
//  Created by Petro Korienev on 4/8/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Quick
import Nimble
@testable import Scoper

class ContextSpec: QuickSpec {
    private struct Constants {
        static let helloWorldString = "Hello world"
        static let helloWorldString2 = "Hello world2"
        static let stringKey1 = "stringKey1"
        static let stringKey2 = "stringKey2"
        static let oneNumber = 1
    }
    
    override func spec() {
        describe("Getter, setter, subscripts") {
            
            enum TestEnum: String, CustomStringConvertible {
                case testEnumCase1
                case testEnumCase2
                
                var description: String { return rawValue }
            }
            
            var stringContext: Scoper.Context<String>!
            var customContext: Scoper.Context<TestEnum>!
            
            beforeEach {
                stringContext = Scoper.Context<String>()
                customContext = Scoper.Context<TestEnum>()
            }
            afterEach {
                stringContext = nil
                customContext = nil
            }
            context("working with string context") {
                it("should put, then get") {
                    stringContext.put(value: Constants.helloWorldString, for: Constants.stringKey1)
                    let result: String? = stringContext.getValue(for: Constants.stringKey1)
                    expect(result) == Constants.helloWorldString
                }
                it("should get nil without put") {
                    let result: String? = stringContext.getValue(for: Constants.stringKey1)
                    expect(result).to(beNil())
                }
                it("should overwrite on put") {
                    stringContext.put(value: Constants.helloWorldString, for: Constants.stringKey1)
                    stringContext.put(value: Constants.helloWorldString2, for: Constants.stringKey1)
                    let result: String? = stringContext.getValue(for: Constants.stringKey1)
                    expect(result) == Constants.helloWorldString2
                }
                it("should remove") {
                    stringContext.put(value: Constants.helloWorldString, for: Constants.stringKey1)
                    var result: String? = stringContext.getValue(for: Constants.stringKey1)
                    expect(result) == Constants.helloWorldString
                    stringContext.removeValue(for: Constants.stringKey1)
                    result = stringContext.getValue(for: Constants.stringKey1)
                    expect(result).to(beNil())
                }
                it("should separate values by keys") {
                    stringContext.put(value: Constants.helloWorldString, for: Constants.stringKey1)
                    stringContext.put(value: Constants.helloWorldString2, for: Constants.stringKey2)
                    let result1: String? = stringContext.getValue(for: Constants.stringKey1)
                    let result2: String? = stringContext.getValue(for: Constants.stringKey2)
                    expect(result1) == Constants.helloWorldString
                    expect(result2) == Constants.helloWorldString2
                }
                it("should perform type inference on get") {
                    stringContext.put(value: Constants.oneNumber, for: Constants.stringKey1)
                    let resultString: String? = stringContext.getValue(for: Constants.stringKey1)
                    let resultInt: Int? = stringContext.getValue(for: Constants.stringKey1)
                    expect(resultString).to(beNil())
                    expect(resultInt) == Constants.oneNumber
                }
                it("should support type conversion through Any on get") {
                    stringContext.put(value: Constants.oneNumber, for: Constants.stringKey1)
                    let result: Any? = stringContext.getValue(for: Constants.stringKey1)
                    let resultString = result as? String
                    let resultInt = result as? Int
                    expect(resultString).to(beNil())
                    expect(resultInt) == Constants.oneNumber
                }
                it("should support C struct types") {
                    let rect = CGRect(x: Constants.oneNumber, y: Constants.oneNumber,
                                      width: Constants.oneNumber, height: Constants.oneNumber)
                    stringContext.put(value: rect, for: Constants.stringKey1)
                    let result: CGRect? = stringContext.getValue(for: Constants.stringKey1)
                    expect(result) == rect
                }
                it("should support bridgeable types") {
                    let array = [Constants.helloWorldString, Constants.helloWorldString2]
                    stringContext.put(value: array, for: Constants.stringKey1)
                    let result: NSArray? = stringContext.getValue(for: Constants.stringKey1)
                    expect(result) == array as NSArray
                }
            }
            context("working with string context") {
                it("should put, then get") {
                    customContext.put(value: Constants.helloWorldString, for: .testEnumCase1)
                    let result: String? = customContext.getValue(for: .testEnumCase1)
                    expect(result) == Constants.helloWorldString
                }
                it("should get nil without put") {
                    let result: String? = customContext.getValue(for: .testEnumCase1)
                    expect(result).to(beNil())
                }
                it("should overwrite on put") {
                    customContext.put(value: Constants.helloWorldString, for: .testEnumCase1)
                    customContext.put(value: Constants.helloWorldString2, for: .testEnumCase1)
                    let result: String? = customContext.getValue(for: .testEnumCase1)
                    expect(result) == Constants.helloWorldString2
                }
                it("should remove") {
                    customContext.put(value: Constants.helloWorldString, for: .testEnumCase1)
                    var result: String? = customContext.getValue(for: .testEnumCase1)
                    expect(result) == Constants.helloWorldString
                    customContext.removeValue(for: .testEnumCase1)
                    result = customContext.getValue(for: .testEnumCase1)
                    expect(result).to(beNil())
                }
                it("should separate values by keys") {
                    customContext.put(value: Constants.helloWorldString, for: .testEnumCase1)
                    customContext.put(value: Constants.helloWorldString2, for: .testEnumCase2)
                    let result1: String? = customContext.getValue(for: .testEnumCase1)
                    let result2: String? = customContext.getValue(for: .testEnumCase2)
                    expect(result1) == Constants.helloWorldString
                    expect(result2) == Constants.helloWorldString2
                }
                it("should perform type inference on get") {
                    customContext.put(value: Constants.oneNumber, for: .testEnumCase1)
                    let resultString: String? = customContext.getValue(for: .testEnumCase1)
                    let resultInt: Int? = customContext.getValue(for: .testEnumCase1)
                    expect(resultString).to(beNil())
                    expect(resultInt) == Constants.oneNumber
                }
                it("should support type conversion through Any on get") {
                    customContext.put(value: Constants.oneNumber, for: .testEnumCase1)
                    let result: Any? = customContext.getValue(for: .testEnumCase1)
                    let resultString = result as? String
                    let resultInt = result as? Int
                    expect(resultString).to(beNil())
                    expect(resultInt) == Constants.oneNumber
                }
                it("should support C struct types") {
                    let rect = CGRect(x: Constants.oneNumber, y: Constants.oneNumber,
                                      width: Constants.oneNumber, height: Constants.oneNumber)
                    customContext.put(value: rect, for: .testEnumCase1)
                    let result: CGRect? = customContext.getValue(for: .testEnumCase1)
                    expect(result) == rect
                }
                it("should support bridgeable types") {
                    let array = [Constants.helloWorldString, Constants.helloWorldString2]
                    customContext.put(value: array, for: .testEnumCase1)
                    let result: NSArray? = customContext.getValue(for: .testEnumCase1)
                    expect(result) == array as NSArray
                }
            }
        }
    }
}
