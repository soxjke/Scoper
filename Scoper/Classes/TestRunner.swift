//
//  TestRunner.swift
//  Scoper
//
//  Created by Petro Korienev on 4/8/18.
//

import Foundation

public final class TestRunner {
    public typealias Completion = (ScopeResult) -> Void
    public static let shared = TestRunner()
    
    private var lock = NSLock()
    private var dispatchQueue = DispatchQueue(label: "Scoper.TestRunner",
                                              qos: .utility)
    private lazy var timer: DispatchSourceTimer = {
        let timer = DispatchSource.makeTimerSource(queue: self.dispatchQueue)
        timer.schedule(deadline: .now(), repeating: 1)
        timer.setEventHandler(handler: self.tick)
        return timer
    }()
    private var queue: [(ScopeProtocol, Completion)] = []
    private var executingScope: ScopeProtocol? = nil
    private init() {}
    
    public func schedule<T>(_ scope: Scope<T>, completion: @escaping Completion) {
        lock.lock()
        defer { lock.unlock() }
        if nil == executingScope {
            scheduleRun(scope, completion: completion)
        }
        else {
            queue.append((scope, completion))
            timer.resume()
        }
    }
    
    private func scheduleRun(_ scope: ScopeProtocol, completion: @escaping Completion) {
        executingScope = scope
        dispatchQueue.async {
            self.run(scope, completion: completion)
        }
    }
    
    private func run(_ scope: ScopeProtocol, completion: @escaping Completion) {
        scope.run(completion: completion)
    }
    
    private func tick() {
        lock.lock()
        defer { lock.unlock() }
        if nil == executingScope {
            if !queue.isEmpty {
                let (scope, completion) = queue.removeFirst()
                scheduleRun(scope, completion: completion)
            }
        }
        if queue.isEmpty {
            timer.suspend()
        }
    }
}
