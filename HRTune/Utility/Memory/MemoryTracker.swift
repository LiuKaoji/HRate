//
//  MemoryTracker.swift
//  HRTune
//
//  Created by kaoji on 5/16/23.
//  Copyright © 2023 kaoji. All rights reserved.
//

import Foundation

protocol AutoMemoryTracking: AnyObject { }

extension AutoMemoryTracking {
    init() {
        self.init()
        MemoryTracker.incrementCount(of: Self.self)
    }
    
    func prepareForDeinit() {
        MemoryTracker.decrementCount(of: Self.self)
    }
}

class MemoryTracker {
    static var instanceCount = [String: Int]()

    static func incrementCount(of classType: AnyClass) {
        let className = NSStringFromClass(classType)
        if let count = instanceCount[className] {
            instanceCount[className] = count + 1
        } else {
            instanceCount[className] = 1
        }
        print("\(className) count: \(instanceCount[className]!)")
    }

    static func decrementCount(of classType: AnyClass) {
        let className = NSStringFromClass(classType)
        if let count = instanceCount[className] {
            instanceCount[className] = count - 1
        } else {
            instanceCount[className] = 0
        }
        print("\(className) count: \(instanceCount[className]!)")
    }
}

class MyClass: AutoMemoryTracking {
    deinit {
        self.prepareForDeinit()
    }
}
