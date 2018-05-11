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
        private(set) var timeout: TimeInterval = 60
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

extension TestCase {
    fileprivate func runWorker( timedOut: inout Bool,
                                semaphore: DispatchSemaphore,
                                options: TestOptions,
                                run: Int,
                                capture: CaptureProtocol,
                                context: Context<ContextKeyType>,
                                startResults: RawResults,
                                endResults: RawResults) {
        let internalComplete: CompletionCallback = { [timedOut] in
            guard !timedOut else { return }
            capture.capture(endResults, run: run, options: options)
            semaphore.signal()
        }
        variables.entryPointQueue.async {
            capture.capture(startResults, run: run, options: options)
            if self.variables.async {
                self.variables.worker?(context, internalComplete)
            }
            else {
                self.variables.worker?(context, {})
                internalComplete()
            }
        }
    }
    
    internal func run(timedOut: inout Bool,
                      options: TestOptions,
                      beforeEach: Scope<ContextKeyType>.Worker?,
                      afterEach: Scope<ContextKeyType>.Worker?,
                      logger: Logger,
                      capture: CaptureProtocol,
                      context: Context<ContextKeyType>) -> Result {
        let semaphore = DispatchSemaphore(value: 0)
        
        reportTestCaseStart(logger, options: options)
        
        let startResults = RawResults(numberOfRuns: variables.numberOfRuns)
        let endResults = RawResults(numberOfRuns: variables.numberOfRuns)
        (0..<variables.numberOfRuns).forEach { (run) in
            guard !timedOut else { return }
            
            reportTestCaseRunStart(logger, run: run, options: options)
            
            beforeEach?(context)
            
            runWorker(timedOut: &timedOut,
                      semaphore: semaphore,
                      options: options,
                      run: run,
                      capture: capture,
                      context: context,
                      startResults: startResults,
                      endResults: endResults)
            
            let result = semaphore.wait(timeout: DispatchTime.now() + variables.timeout)
            if result == .timedOut {
                timedOut = true
                reportTimeout(logger, run: run)
            }
            else {
                afterEach?(context)
            }
            
            reportTestCaseRunComplete(logger, run: run, options: options)
        }
        
        let result = Result(startMeasurements: startResults, endMeasurements: endResults)
        reportTestCaseComplete(logger, result: result, options: options)
        return result
    }
}

public typealias DefaultTestCase = TestCase<String>

extension TestCase {
    func reportTimeout(_ logger: Logger, run: Int) {
        logger("Test case \"" + variables.name + "\" timed out on run #" + String(describing: run) +
            " after waiting for " + String(describing:variables.timeout) + " seconds. Terminating.")
    }
    func reportTestCaseStart(_ logger: Logger, options: TestOptions) {
        if options.contains(.logProgress) { logger("Test case \"" + variables.name + "\" started") }
    }
    func reportTestCaseRunStart(_ logger: Logger, run: Int, options: TestOptions) {
        if options.contains(.logProgress) { logger("Test case \"" + variables.name + "\", run " +
            String(describing: run + 1) + " out of " + String(describing: variables.numberOfRuns) + " started") }
    }
    func reportTestCaseRunComplete(_ logger: Logger, run: Int, options: TestOptions) {
        if options.contains(.logProgress) { logger("Test case \"" + variables.name + "\", run " +
            String(describing: run + 1) + " out of " + String(describing: variables.numberOfRuns) + " completed") }
    }
    func reportTestCaseComplete(_ logger: Logger, result: Result, options: TestOptions) {
        if options.contains(.logProgress) { logger("Test case \"" + variables.name + "\" completed") }
        if options.contains(.logResults) { logger("Test case \"" + variables.name + "\" results:\n" + result.description(options: options)) }
    }
}
