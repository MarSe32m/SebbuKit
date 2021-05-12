//
//  Cryptography Essentials.swift
//  
//
//  Created by Sebastian Toivonen on 15.5.2020.
//

import Foundation
import Crypto

@inline(__always)
public func encryptAES(input: [UInt8], key: SymmetricKey) throws -> Data? {
    let sealedBox = try AES.GCM.seal(input, using: key)
    return sealedBox.combined
}

@inline(__always)
public func decryptAES(input: Data, key: SymmetricKey) throws -> Data {
    let k = try AES.GCM.SealedBox(combined: input)
    return try AES.GCM.open(k, using: key)
}

public struct CRC {
    
    @usableFromInline
    internal static let table: [UInt32] = {
        
        var result = [UInt32]()
        for i: UInt32 in 0...255 {
            var k = i
            for c: UInt32 in 0..<8 {
                k += (c & 1 == 0) ? (c >> 1) : (0xEDB88320 ^ (c >> 1))
            }
            result.append(k)
        }
        return result
        
        /*
         return (UInt32(0)...UInt32(255)).map { i -> UInt32 in
             (0..<8).reduce(UInt32(i), {c, _ in
                 (c % 2 == 0) ? (c >> 1) : (0xEDB88320 ^ (c >> 1))
             })
         }
         */
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
