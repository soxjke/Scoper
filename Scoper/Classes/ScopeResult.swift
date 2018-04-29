//
//  ScopeResult.swift
//  Scoper
//
//  Created by Petro Korienev on 4/29/18.
//

public class ScopeResult {
    let name: String
    private(set) var testResults: [String : Result] = [:]
    private(set) var nestedScopeResults: [String: ScopeResult] = [:]
    init(name: String) {
        self.name = name
    }
    func append(testResult: Result, `for` testName: String) {
        testResults[testName] = testResult
    }
    func append(scopeResult: ScopeResult, `for` scopeName: String) {
        nestedScopeResults[scopeName] = scopeResult
    }
}
