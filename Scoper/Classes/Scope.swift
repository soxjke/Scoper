//
//  Scope.swift
//  Scoper
//
//  Created by Petro Korienev on 4/7/18.
//

protocol ScopeProtocol {
    func run(isNested: Bool, completion: @escaping TestRunner.Completion)
}

public class Scope<ContextKeyType: CustomStringConvertible>: ScopeProtocol {
    // MARK - Helper types definitions
    public typealias Worker = (Context<ContextKeyType>) -> Void
    
    internal struct Variables {
        private(set) var before: Worker?
        fileprivate mutating func set(before: @escaping Worker)
            { self.before = before }
        private(set) var beforeEach: Worker?
        fileprivate mutating func set(beforeEach: @escaping Worker)
            { self.beforeEach = beforeEach }
        private(set) var after: Worker?
        fileprivate mutating func set(after: @escaping Worker)
            { self.after = after }
        private(set) var afterEach: Worker?
        fileprivate mutating func set(afterEach: @escaping Worker)
            { self.afterEach = afterEach }
        private(set) var name: String = UUID().uuidString
        fileprivate mutating func set(name: String)
            { self.name = name }
        private(set) var options: TestOptions = .basic
        fileprivate mutating func set(options: TestOptions)
            { self.options = options }
        private(set) var scopes: [Scope<ContextKeyType>] = []
        fileprivate mutating func append(scope: Scope<ContextKeyType>)
            { self.scopes.append(scope) }
        private(set) var testCases: [TestCase<ContextKeyType>] = []
        fileprivate mutating func append(testCase: TestCase<ContextKeyType>)
            { self.testCases.append(testCase) }
        init() {}
    }

    public class Builder: BuilderProtocol {
        fileprivate var variables = Variables()
        
        public init() {}
        public func build() -> Scope<ContextKeyType> {
            return Result(self)
        }
        public func before(_ before: @escaping Worker) -> Self {
            variables.set(before: before); return self
        }
        public func beforeEach(_ beforeEach: @escaping Worker) -> Self {
            variables.set(beforeEach: beforeEach); return self
        }
        public func after(_ after: @escaping Worker) -> Self {
            variables.set(after: after); return self
        }
        public func afterEach(_ afterEach: @escaping Worker) -> Self {
            variables.set(afterEach: afterEach); return self
        }
        public func name(_ name: String) -> Self {
            variables.set(name: name); return self
        }
        public func options(_ options: TestOptions) -> Self {
            variables.set(options: options); return self
        }
        public func nestedScope(_ nestedScope: Scope<ContextKeyType>) -> Self {
            variables.append(scope: nestedScope); return self
        }
        public func testCase(_ testCase: TestCase<ContextKeyType>) -> Self {
            variables.append(testCase: testCase); return self
        }
    }
    
    // MARK - Variables definitions
    var variables: Variables
    var capture: CaptureProtocol = Capture()
    var logger: Logger = defaultLogger
    lazy var scopeResult: ScopeResult = ScopeResult(name: self.variables.name)
    var context = Context<ContextKeyType>()
    fileprivate let dispatchQueue = DispatchQueue(label: "Scoper.Scope",
                                                  qos: .utility)
    
    fileprivate init(_ builder: Builder) {
        variables = builder.variables
    }
}

extension Scope {
    func run(isNested: Bool = false, completion: @escaping TestRunner.Completion) {
        let mainClosure: () -> Void = {
            var timedOut: Bool = false
            
            self.reportScopeStart(options: self.variables.options)
            self.variables.before?(self.context)
            
            self.variables.testCases.forEach { testCase in
                guard !timedOut else { return }
                self.scopeResult.append(testResult: testCase.run(timedOut: &timedOut,
                                                                 options: self.variables.options,
                                                                 beforeEach: self.variables.beforeEach,
                                                                 afterEach: self.variables.afterEach,
                                                                 logger: self.logger,
                                                                 capture: self.capture,
                                                                 context: self.context),
                                        for: testCase.variables.name)
            }
            
            self.variables.scopes.forEach { nestedScope in
                self.reportNestedScopeStart(scope: nestedScope, options: self.variables.options)
                /*
                    Merge options, share context with the nested scope
                */
                nestedScope.variables.set(options: nestedScope.variables.options.union(self.variables.options))
                nestedScope.context = self.context
                nestedScope.run(isNested: true) { nestedScopeResult in
                    self.scopeResult.append(scopeResult: nestedScopeResult, for: nestedScope.variables.name)
                }
                self.reportNestedScopeComplete(scope: nestedScope, options: self.variables.options)
            }
            
            self.variables.after?(self.context)
            self.reportScopeComplete(options: self.variables.options)
            
            completion(self.scopeResult)
        }
        
        return isNested ? mainClosure() : dispatchQueue.async(execute: mainClosure)
    }
}

public typealias DefaultScope = Scope<String>

extension Scope {
    func reportScopeStart(options: TestOptions) {
        if options.contains(.logProgress) { logger("Scope \"" + variables.name + "\" started") }
    }
    func reportScopeComplete(options: TestOptions) {
        if options.contains(.logProgress) { logger("Scope \"" + variables.name + "\" completed") }
    }
    func reportNestedScopeStart(scope: Scope<ContextKeyType>, options: TestOptions) {
        if options.contains(.logProgress) { logger("Nested scope \"" + scope.variables.name + "\" is about to start") }
    }
    func reportNestedScopeComplete(scope: Scope<ContextKeyType>, options: TestOptions) {
        if options.contains(.logProgress) { logger("Nested scope \"" + scope.variables.name + "\" recently completed") }
    }
}
