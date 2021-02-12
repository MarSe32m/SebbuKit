//
//  DataStructures.swift
//  
//
//  Created by Sebastian Toivonen on 31.1.2020.
//  Copyright © 2020 Sebastian Toivonen. All rights reserved.
//

public final class Grid<T> {
    var matrix:[T]
    var rows:Int
    var columns:Int
    
    public init(rows:Int, columns:Int, defaultValue:T) {
        self.rows = rows
        self.columns = columns
        matrix = Array(repeating:defaultValue,count:(rows*columns))
    }
    
    internal func indexIsValidFor(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    
    public subscript(col:Int, row:Int) -> T? {
        get{
            if indexIsValidFor(row: row, column: col) {
                return matrix[columns * row + col]
            } else {
                return nil
            }
        }
        set{
            if indexIsValidFor(row: row, column: col) {
                if let newValue = newValue {
                    matrix[columns * row + col] = newValue
                }
            }
        }
    }
}

public struct BitSet {
    private(set) public var size: Int
    
    private let N = 64
    public typealias Word = UInt64
    fileprivate(set) public var words: [Word]
    
    public var cardinality: Int {
        var count = 0
        for var x in words {
            while x != 0 {
                let y = x & ~(x - 1)
                x = y ^ x
                count += 1
            }
        }
        return count
    }
    
    public init(size: Int) {
        precondition(size > 0)
        self.size = size
        
        let n = (size + (N - 1)) / N
        words = [Word](repeating: 0, count: n)
    }
    
    private func indexOf(_ i: Int) -> (Int, Word) {
        precondition(i >= 0 && i < size)
        let o = i / N
        let m = Word(i - o * N)
        return (o, 1 << m)
    }
    
    public mutating func set(_ i: Int) {
        let (j, m) = indexOf(i)
        words[j] |= m
    }
    
    public mutating func clear(_ i: Int) {
        let (j, m) = indexOf(i)
        words[j] &= ~m
    }
    
    public func isSet(_ i: Int) -> Bool {
        let (j, m) = indexOf(i)
        return (words[j] & m) != 0
    }
    
    public subscript(i: Int) -> Bool {
        get { isSet(i) }
        set { if newValue { set(i) } else { clear(i) } }
    }
}
