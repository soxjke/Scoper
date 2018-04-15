//
//  Scope.swift
//  Scoper
//
//  Created by Petro Korienev on 4/7/18.
//

protocol ScopeProtocol {
    func run(completion: @escaping TestRunner.Completion)
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
    let context = Context<ContextKeyType>()
    fileprivate let dispatchQueue = DispatchQueue(label: "Scoper.Scope",
                                                  qos: .utility)
    
    fileprivate init(_ builder: Builder) {
        variables = builder.variables
    }
}

extension Scope {
    func run(completion: @escaping TestRunner.Completion) {
        dispatchQueue.async {
            var timedOut: Bool = false
            self.variables.before?(self.context)
            self.variables.testCases.forEach { testCase in
                guard !timedOut else { return }
                let semaphore = DispatchSemaphore(value: 0)
                let startResults = RawResults(numberOfRuns: testCase.variables.numberOfRuns)
                let endResults = RawResults(numberOfRuns: testCase.variables.numberOfRuns)
                (0..<testCase.variables.numberOfRuns).forEach { (run) in
                    guard !timedOut else { return }
                    self.variables.beforeEach?(self.context)
                    let internalComplete: TestCase.CompletionCallback = {
                        guard !timedOut else { return }
                        self.capture.capture(endResults, run: run, options: self.variables.options)
                        semaphore.signal()
                    }
                    testCase.variables.entryPointQueue.async {
                        self.capture.capture(startResults, run: run, options: self.variables.options)
                        if testCase.variables.async {
                            testCase.variables.worker?(self.context, internalComplete)
                        }
                        else {
                            testCase.variables.worker?(self.context, {})
                            internalComplete()
                        }
                    }
                    self.variables.afterEach?(self.context)
                    let result = semaphore.wait(timeout: DispatchTime.now() + testCase.variables.timeout)
                    if result == .timedOut {
                        timedOut = true
                        self.reportTimeout(testCase: testCase, run: run, options: self.variables.options)
                    }
                }
                print(startResults)
                print(endResults)
                print("complete")
            }
            self.variables.after?(self.context)
        }
    }
    
    private func reportTimeout(testCase: TestCase<ContextKeyType>, run: Int, options: TestOptions) {
        
    }
}

public typealias DefaultScope = Scope<String>
