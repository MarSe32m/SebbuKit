//
//  IntegerExtensions.swift
//  
//
//  Created by Sebastian Toivonen on 15.9.2020.
//

public func isPrime<T: FixedWidthInteger>(number: T) -> Bool {
    number.isPrime()
}

public extension FixedWidthInteger {
    func extractBit(at index: Self) -> Bool {
        Int(truncatingIfNeeded: self &>> index) & 1 != 0
    }
    
    mutating func setBit(at index: Self) {
        self |= (1 &<< index)
    }
    
    mutating func clearBit(at index: Self) {
        self &= ~(1 &<< index)
    }
    
    mutating func updateBit(at index: Self, to newValue: Bool) {
        if newValue {
            setBit(at: index)
        } else {
            clearBit(at: index)
        }
    }
    
    func isPrime() -> Bool {
        if self <= 3 { return self > 1 }
        if self % 2 == 0 || self % 3 == 0 { return false }
        var i: Self = 5
        while i * i <= self {
            if self % i == 0 || self % (i + 2) == 0 { return false }
            i += 6
        }
        return true
    }
}
