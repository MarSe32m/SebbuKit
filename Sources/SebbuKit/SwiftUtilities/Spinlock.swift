//
//  Spinlock.swift
//  
//
//  Created by Sebastian Toivonen on 29.6.2020.
//

import Foundation
import NIOConcurrencyHelpers

public final class Spinlock {
    #warning("TODO: Replace with Swift native atomics when they are out")
    private let flag = NIOAtomic.makeAtomic(value: false)
    
    public func lock() {
        while flag.compareAndExchange(expected: false, desired: true) {}
    }
    
    public func tryLock() -> Bool {
        return flag.compareAndExchange(expected: false, desired: true)
    }
    
    public func unlock() {
        flag.store(false)
    }
    
    public func withLockVoid(_ closure: () -> Void) {
        lock()
        closure()
        unlock()
    }
}
