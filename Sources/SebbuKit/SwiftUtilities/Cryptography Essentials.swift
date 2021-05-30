//
//  Cryptography Essentials.swift
//  
//
//  Created by Sebastian Toivonen on 15.5.2020.
//
//  Copyright © 2021 Sebastian Toivonen. All rights reserved.

import Foundation
import Crypto

@inline(__always)
public func encryptAES(input: [UInt8], key: SymmetricKey) throws -> [UInt8]? {
    let sealedBox = try AES.GCM.seal(input, using: key)
    if let combined = sealedBox.combined {
        return [UInt8](combined)
    }
    return nil
}

@inline(__always)
public func decryptAES(input: [UInt8], key: SymmetricKey) throws -> [UInt8] {
    let box = try AES.GCM.SealedBox(combined: input)
    return try [UInt8](AES.GCM.open(box, using: key))
}

@inline(__always)
public func decryptAES(input: Data, key: SymmetricKey) throws -> Data {
    let box = try AES.GCM.SealedBox(combined: input)
    return try AES.GCM.open(box, using: key)
}

public struct CRC {
    @usableFromInline
    internal static let table: [UInt32] = {
         return (UInt32(0)...UInt32(255)).map { i -> UInt32 in
             (0..<8).reduce(UInt32(i), {c, _ in
                 (c % 2 == 0) ? (c >> 1) : (0xEDB88320 ^ (c >> 1))
             })
         }
         
    }()
    
    @inline(__always)
    public static func checksum(_ buffer: UnsafeRawBufferPointer) -> UInt32 {
        return ~(buffer.reduce(~UInt32(0), {crc, byte in
            (crc >> 8) ^ table[(Int(crc) ^ Int(byte)) & 0xFF]
        }))
    }
    
    @inline(__always)
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
