//
//  TestCase.swift
//  Scoper
//
//  Created by Petro Korienev on 4/7/18.
//

public class TestCase<ContextKeyType: CustomStringConvertible> {
    // MARK - Helper types definitions
    public typealias CompletionCallback = () -> Void
    public typealias Worker = (Context<ContextKeyType>, CompletionCallback) -> Void
    
    internal struct Variables {
        private(set) var worker: Worker?
        fileprivate mutating func set(worker: @escaping Worker)
            { self.worker = worker }
        private(set) var async: Bool = false
        fileprivate mutating func set(async: Bool)
            { self.async = async }
        private(set) var numberOfRuns: Int = 10
        fileprivate mutating func set(numberOfRuns: Int)
            { self.numberOfRuns = numberOfRuns }
        private(set) var name: String = UUID().uuidString
        fileprivate mutating func set(name: String)
            { self.name = name }
        private(set) var timeout: TimeInterval = 10
        fileprivate mutating func set(timeout: TimeInterval)
            { self.timeout = timeout }
        private(set) var entryPointQueue: DispatchQueue = DispatchQueue.main
        fileprivate mutating func set(entryPointQueue: DispatchQueue)
            { self.entryPointQueue = entryPointQueue }
        init() {}
    }
    
    public class Builder: BuilderProtocol {
        fileprivate var variables = Variables()
        
        public init() {}
        public func build() -> TestCase<ContextKeyType> {
            return Result(self)
        }
        public func worker(_ worker: @escaping Worker) -> Self {
            variables.set(worker: worker); return self
        }
        public func async(_ async: Bool = true) -> Self {
            variables.set(async: async); return self
        }
        public func numberOfRuns(_ numberOfRuns: Int) -> Self {
            variables.set(numberOfRuns: numberOfRuns); return self
        }
        public func name(_ name: String) -> Self {
            variables.set(name: name); return self
        }
        public func timeout(_ timeout: TimeInterval) -> Self {
            variables.set(timeout: timeout); return self
        }
        public func entryPointQueue(_ entryPointQueue: DispatchQueue) -> Self {
            variables.set(entryPointQueue: entryPointQueue); return self
        }
    }
    
    // MARK - Variables definitions
    internal var variables: Variables
    
    fileprivate init(_ builder: Builder) {
        variables = builder.variables
    }
}
