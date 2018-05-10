//
//  main.swift
//  Algorithms
//
//  Created by Petro Korienev on 5/9/18.
//  Copyright © 2018 Sigma Software. All rights reserved.
//

import Foundation
import Scoper

let scope = DefaultScope.Builder()
    .name("Permutations")
    .options([.runTime, .logResults])
    .before { context in
        context.put(value: [1, 2, 3, 4, 5, 6, 7, 8, 9], for: "SourceArray")
    }
    .testCase(
        DefaultTestCase.Builder()
            .name("Mutating version")
            .worker { context, _ in
                let source: [Int] = context.getValue(for: "SourceArray")!
                let _ = source.permutationsOverMutations()
            }
            .build()
    )
    .testCase(
        DefaultTestCase.Builder()
            .name("Mutating version over append alloc")
            .worker { context, _ in
                let source: [Int] = context.getValue(for: "SourceArray")!
                let _ = source.permutationsOverMutationsWithAppendAlloc()
            }
            .build()
    )
//    .testCase(
//        DefaultTestCase.Builder()
//            .name("Functional mutating version")
//            .worker { context, _ in
//                let source: [Int] = context.getValue(for: "SourceArray")!
//                let _ = source.permutationsOverMutationsFunctional()
//            }
//            .build()
//    )
//    .testCase(
//        DefaultTestCase.Builder()
//            .name("Functional mutating version over append alloc")
//            .worker { context, _ in
//                let source: [Int] = context.getValue(for: "SourceArray")!
//                let _ = source.permutationsOverMutationsFunctionalWithAppendAlloc()
//            }
//            .build()
//    )
//    .testCase(
//        DefaultTestCase.Builder()
//            .name("Optimized functional mutating version")
//            .worker { context, _ in
//                let source: [Int] = context.getValue(for: "SourceArray")!
//                let _ = source.permutationsOverMutationsFunctionalOptimized()
//            }
//            .build()
//    )
//    .testCase(
//        DefaultTestCase.Builder()
//            .name("Optimized functional mutating version over append alloc")
//            .worker { context, _ in
//                let source: [Int] = context.getValue(for: "SourceArray")!
//                let _ = source.permutationsOverMutationsFunctionalOptimizedWithAppendAlloc()
//            }
//            .build()
//    )
//    .testCase(
//        DefaultTestCase.Builder()
//            .name("Optimized functional mutating version - 2")
//            .worker { context, _ in
//                let source: [Int] = context.getValue(for: "SourceArray")!
//                let _ = source.permutationsOverMutationsFunctionalOptimized2()
//            }
//            .build()
//    )
//    .testCase(
//        DefaultTestCase.Builder()
//            .name("Optimized functional mutating version over append alloc - 2")
//            .worker { context, _ in
//                let source: [Int] = context.getValue(for: "SourceArray")!
//                let _ = source.permutationsOverMutationsFunctionalOptimizedWithAppendAlloc2()
//            }
//            .build()
//    )
//    .testCase(
//        DefaultTestCase.Builder()
//            .name("Optimized functional mutating version - 3")
//            .worker { context, _ in
//                let source: [Int] = context.getValue(for: "SourceArray")!
//                let _ = source.permutationsOverMutationsFunctionalOptimized3()
//            }
//            .build()
//    )
//    .testCase(
//        DefaultTestCase.Builder()
//            .name("Optimized functional mutating version over append alloc - 3")
//            .worker { context, _ in
//                let source: [Int] = context.getValue(for: "SourceArray")!
//                let _ = source.permutationsOverMutationsFunctionalOptimizedWithAppendAlloc3()
//            }
//            .build()
//    )
//    .testCase(
//        DefaultTestCase.Builder()
//            .name("Optimized functional mutating version - 4")
//            .worker { context, _ in
//                let source: [Int] = context.getValue(for: "SourceArray")!
//                let _ = source.permutationsOverMutationsFunctionalOptimized4()
//            }
//            .build()
//    )
//    .testCase(
//        DefaultTestCase.Builder()
//            .name("Optimized functional mutating version over append alloc - 4")
//            .worker { context, _ in
//                let source: [Int] = context.getValue(for: "SourceArray")!
//                let _ = source.permutationsOverMutationsFunctionalOptimizedWithAppendAlloc4()
//            }
//            .build()
//    )
    .testCase(
        DefaultTestCase.Builder()
            .name("Concurrent version - 1")
            .worker { context, _ in
                let source: [Int] = context.getValue(for: "SourceArray")!
                let _ = source.permutationsConcurrent(concurrentThreads: 8)
            }
            .build()
    )
    .testCase(
        DefaultTestCase.Builder()
            .name("Concurrent version - 2")
            .worker { context, _ in
                let source: [Int] = context.getValue(for: "SourceArray")!
                let _ = source.permutationsConcurrent(concurrentThreads: 8, flatMapAtTheEnd: true)
            }
            .build()
    )
    .testCase(
        DefaultTestCase.Builder()
            .name("Concurrent version - 3")
            .worker { context, _ in
                let source: [Int] = context.getValue(for: "SourceArray")!
                let _ = source.permutationsConcurrentUnsafePointer(concurrentThreads: 8)
            }
            .build()
    )
//    .testCase(
//        DefaultTestCase.Builder()
//            .name("Functional recursive permutations")
//            .worker { context, _ in
//                let source: [Int] = context.getValue(for: "SourceArray")!
//                let _ = source.permutations()
//            }
//            .build()
//    )
    .build()

TestRunner.shared.schedule(scope) { _ in }

CFRunLoopRun()

