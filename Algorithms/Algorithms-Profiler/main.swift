//
//  main.swift
//  Algorithms-Profiler
//
//  Created by Petro Korienev on 5/10/18.
//  Copyright © 2018 Sigma Software. All rights reserved.
//

import Foundation

let source: [Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
//autoreleasepool {
//    let startDate = Date()
//    let resultArray = source.permutationsOverMutationsFunctionalOptimized4()
//    let duration = Date().timeIntervalSince(startDate)
//    print(duration)
//}
//autoreleasepool {
//    let startDate = Date()
//    let resultArray = source.permutationsConcurrent(concurrentThreads: 8)
//    let duration = Date().timeIntervalSince(startDate)
//    print(duration)
//}
//autoreleasepool {
//    let startDate = Date()
//    let resultArray = source.permutationsConcurrent(concurrentThreads: 8, flatMapAtTheEnd: true)
//    let duration = Date().timeIntervalSince(startDate)
//    print(duration)
//}
autoreleasepool {
    let startDate = Date()
    let resultArray = source.permutationsConcurrentUnsafePointer(concurrentThreads: 8)
    let duration = Date().timeIntervalSince(startDate)
    print(duration)
}
