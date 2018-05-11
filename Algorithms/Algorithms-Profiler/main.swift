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
//autoreleasepool {
//    let startDate = Date()
//    let resultArray = source.permutationsConcurrentUnsafePointer(concurrentThreads: 8)
//    let duration = Date().timeIntervalSince(startDate)
//    print(duration)
//}

protocol Randomable {
    static func random() -> Self
}

extension Int: Randomable {
    static func random() -> Int {
        return Int(arc4random_uniform(UInt32.max))
    }
}

extension Array where Element: Randomable{
    static func random(count randomCount: Int) -> Array {
        var array = Array()
        array.reserveCapacity(randomCount)
        (0...randomCount).forEach { _ in array.append( Element.random() ) }
        return array
    }
}

let sourceArray: [Int] = .random(count: 1000000)

func quicksort<T: Comparable>(_ a: [T]) -> [T] {
    guard a.count > 1 else { return a }
    
    let pivot = a[a.count/2]
    let less = a.filter { $0 < pivot }
    let equal = a.filter { $0 == pivot }
    let greater = a.filter { $0 > pivot }
    
    return quicksort(less) + equal + quicksort(greater)
}

func combSort (_ input: [Int]) -> [Int] {
    var copy: [Int] = input
    var gap = copy.count
    let shrink = 1.3
    
    while gap > 1 {
        gap = (Int)(Double(gap) / shrink)
        if gap < 1 {
            gap = 1
        }
        
        var index = 0
        while !(index + gap >= copy.count) {
            if copy[index] > copy[index + gap] {
                copy.swapAt(index, index + gap)
            }
            index += 1
        }
    }
    return copy
}

//autoreleasepool {
//    let startDate = Date()
//    let resultArray = sourceArray.sorted()
//    let duration = Date().timeIntervalSince(startDate)
//    print(duration)
//}
//autoreleasepool {
//    let startDate = Date()
//    let resultArray = quicksort(sourceArray)
//    let duration = Date().timeIntervalSince(startDate)
//    print(duration)
//}
//autoreleasepool {
//    let startDate = Date()
//    let resultArray = combSort(sourceArray)
//    let duration = Date().timeIntervalSince(startDate)
//    print(duration)
//}

struct PermutationSequence<Element : Comparable> : Sequence, IteratorProtocol {

    private var current: [Element]
    private var firstIteration = true

    init(startingFrom elements: [Element]) {
        self.current = elements
    }

    init<S : Sequence>(_ elements: S) where S.Iterator.Element == Element {
        self.current = elements.sorted()
    }

//    mutating func next() -> [Element]? {
//
//        // if it's the first iteration, we simply return the current array.
//        if firstIteration {
//            firstIteration = false
//            return current
//        }
//
//        // do mutation – if the array has changed, then return it,
//        // else we're at the end of the sequence.
//        return current.permute() ? current : nil
//    }
    
    mutating func next() -> [Element]? {
    
        var continueIterating = true
    
        // if it's the first iteration, we avoid doing the permute() and reset the flag.
        if firstIteration {
            firstIteration = false
        } else {
            continueIterating = current.permute()
        }
    
        // if the array changed (and it isn't the first iteration), then return it,
        // else we're at the end of the sequence.
        return continueIterating ? current : nil
    }
}


struct PermutationSequence2<Element : Comparable> : Sequence {
    
    // constant copy of the elements to pass to the iterator on its creation.
    let elements: [Element]
    
    init(startingFrom elements: [Element]) {
        self.elements = elements
    }
    
    init<S : Sequence>(_ elements: S) where S.Iterator.Element == Element {
        self.elements = elements.sorted()
    }
    
    struct Iterator : IteratorProtocol {
        
        private var current: [Element]
        private var firstIteration = true
        
        // you should create a PermutationSequence rather than invoking this
        // initialiser directly.
        fileprivate init(startingFrom elements: [Element]) {
            self.current = elements
        }
        
        mutating func next() -> [Element]? {
            
            var continueIterating = true
            
            // if it's the first iteration, we avoid doing the permute() and reset the flag
            if firstIteration {
                firstIteration = false
            } else {
                continueIterating = current.permute()
            }
            
            // if the array changed (and it isn't the first iteration), then return it,
            // else we're at the end of the sequence.
            return continueIterating ? current : nil
        }
    }
    
    func makeIterator() -> Iterator {
        return Iterator(startingFrom: elements)
    }
}
var count = 0
var start = Date()
var array = Array(1...10)
repeat { count += 1 } while array.permute()
var end = Date()
print(count, end.timeIntervalSince(start))

count = 0
start = Date()
array = Array(1...10)
for _ in PermutationSequence(array) { count += 1 }
end = Date()
print(count, end.timeIntervalSince(start))

count = 0
start = Date()
array = Array(1...10)
for _ in PermutationSequence2(array) { count += 1 }
end = Date()
print(count, end.timeIntervalSince(start))

count = 0
start = Date()
array = Array(1...10)
for _ in array.permutationsOverMutationsWithAppendAlloc() { count += 1 }
end = Date()
print(count, end.timeIntervalSince(start))

