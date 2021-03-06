//
//  IntegerExtensions.swift
//  
//
//  Created by Sebastian Toivonen on 15.9.2020.
//
//  Copyright © 2021 Sebastian Toivonen. All rights reserved.

@inline(__always)
@_specialize(where T == Int)
@_specialize(where T == UInt)
@_specialize(where T == UInt64)
@_specialize(where T == UInt32)
@_specialize(where T == Int64)
@_specialize(where T == Int32)
public func isPrime<T: FixedWidthInteger>(number: T) -> Bool {
    number.isPrime()
}

public extension FixedWidthInteger {
    @inline(__always)
    func extractBit(at index: Self) -> Bool {
        Int(truncatingIfNeeded: self &>> index) & 1 != 0
    }
    
    @inline(__always)
    mutating func setBit(at index: Self) {
        self |= (1 &<< index)
    }
    
    @inline(__always)
    mutating func clearBit(at index: Self) {
        self &= ~(1 &<< index)
    }
    
    @inline(__always)
    mutating func updateBit(at index: Self, to newValue: Bool) {
        if newValue {
            setBit(at: index)
        } else {
            clearBit(at: index)
        }
    }
    
    @inlinable
    @_specialize(where Self == Int)
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
    
    /// Returns the next power of two.
    @inline(__always)
    func nextPowerOf2() -> Self {
        guard self != 0 else {
            return 1
        }
        return 1 << (Self.bitWidth - (self - 1).leadingZeroBitCount)
    }

    /// Returns the previous power of 2, or self if it already is.
    @inline(__always)
    func previousPowerOf2() -> Self {
        guard self != 0 else {
            return 0
        }

        return 1 << ((Self.bitWidth - 1) - self.leadingZeroBitCount)
    }
}
