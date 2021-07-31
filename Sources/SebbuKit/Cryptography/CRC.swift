//
//  CRC.swift
//  
//
//  Created by Sebastian Toivonen on 15.5.2020.
//
//  Copyright © 2021 Sebastian Toivonen. All rights reserved.

public struct CRC {
    @usableFromInline
    internal static let table: [UInt32] = {
        return (UInt32(0)...UInt32(255)).map { i -> UInt32 in
             (0..<8).reduce(UInt32(i), {c, _ in
                 (c % UInt32(2) == 0) ? (c >> UInt32(1)) : (UInt32(0xEDB88320) ^ (c >> 1))
             })
         }
    }()
    
    @inlinable
    public static func checksum(_ buffer: UnsafeRawBufferPointer) -> UInt32 {
        return ~(buffer.reduce(~UInt32(0), {crc, byte in
            (crc >> 8) ^ table[(Int(crc) ^ Int(byte)) & 0xFF]
        }))
    }
    
    @inlinable
    public static func checksum(bytes: [UInt8]) -> UInt32 {
        return checksum(bytes)
    }
    
    @inline(__always)
    public static func checksum(_ bytes: [UInt8]) -> UInt32 {
        return ~(bytes.reduce(~UInt32(0), {crc, byte in
            (crc >> 8) ^ table[(Int(crc) ^ Int(byte)) & 0xFF]
        }))
    }
}
