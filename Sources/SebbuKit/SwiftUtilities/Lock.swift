//
//  Lock.swift
//  
//
//  Created by Sebastian Toivonen on 28.11.2020.
//
//  Copyright © 2021 Sebastian Toivonen. All rights reserved.

import Foundation

public final class Lock: NSLocking {
    private let _lock = NSLock()
    
    public init() {}
    
    public func lock() {
        _lock.lock()
    }
    
    public func lock<T>(_ closure: () -> T) -> T {
        _lock.lock()
        let result = closure()
        _lock.unlock()
        return result
    }
    
    public func lock(_ closure: () -> Void) {
        _lock.lock(); defer{ _lock.unlock() }
        closure()
    }
    
    public func unlock() {
        _lock.unlock()
    }
}
