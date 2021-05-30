//
//  File.swift
//  
//
//  Created by Sebastian Toivonen on 30.5.2021.
//
//  Copyright © 2021 Sebastian Toivonen. All rights reserved.

#if canImport(Foundation)
import Foundation
public extension WritableBitStream {
    @inline(__always)
    mutating func append(_ value: Data) {
        append([UInt8](value))
    }
    
    @inline(__always)
    func packData() -> Data {
        return Data(packBytes())
    }
    
    /// Data encoding
    @inline(__always)
    static func << (bitStream: inout WritableBitStream, value: Data) {
        bitStream.append(value)
    }
}

public extension ReadableBitStream {
    @inlinable
    init(data: Data) {
        self.init(bytes: [UInt8](data))
    }

    @inline(__always)
    mutating func read() throws -> Data {
        return Data(try read() as [UInt8])
    }
    
    /// Data decoding
    @inline(__always)
    static func >> (bitStream: inout ReadableBitStream, value: Data.Type) throws  -> Data {
        return try bitStream.read()
    }
}
#endif
