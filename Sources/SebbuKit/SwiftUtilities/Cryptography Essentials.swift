//
//  Cryptography Essentials.swift
//  
//
//  Created by Sebastian Toivonen on 15.5.2020.
//
//  Copyright © 2021 Sebastian Toivonen. All rights reserved.

import Crypto
import bcrypt

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

@inlinable
public func HMACSHA256Signature(_ data: [UInt8], key: SymmetricKey) -> [UInt8] {
    let signature = HMAC<SHA256>.authenticationCode(for: data, using: key)
    return [UInt8](signature)
}

@inlinable
public func HMACSHA256Verify(_ data: [UInt8], signature: [UInt8], key: SymmetricKey) -> Bool {
    HMAC<SHA256>.isValidAuthenticationCode(signature, authenticating: data, using: key)
}

#if canImport(Foundation)
import Foundation

@inline(__always)
public func decryptAES(input: Data, key: SymmetricKey) throws -> Data {
    let box = try AES.GCM.SealedBox(combined: input)
    return try AES.GCM.open(box, using: key)
}
#endif

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



public struct BCrypt {
    public enum BCryptError: Error {
        case hashFailure
        case saltGenerationFailure
    }
    
    @inlinable
    public static func hash(password: [UInt8], salt: [UInt8]) throws -> [UInt8] {
        var password = password.map { Int8(bitPattern: $0) }
        var salt = salt.map { Int8(bitPattern: $0) }
        var hash = [Int8](repeating: 0, count: 64)
        if bcrypt_hashpw(&password, &salt, &hash) != 0 {
            throw BCryptError.hashFailure
        }
        return hash.map { UInt8(bitPattern: $0) }
    }

    @inlinable
    public static func hash(password: String, salt: [UInt8]) throws -> [UInt8] {
        try hash(password: Array(password.utf8), salt: salt)
    }

    @inlinable
    public static func verify(password: [UInt8], salt: [UInt8], correctHash: [UInt8]) -> Bool {
        guard let newHash = try? hash(password: password, salt: salt) else { return false }
        return slowEquals(newHash, correctHash)
    }

    @inlinable
    public static func verify(password: String, salt: [UInt8], correctHash: [UInt8]) -> Bool {
        verify(password: Array(password.utf8), salt: salt, correctHash: correctHash)
    }

    @inlinable
    public static func generateSalt(iterations: Int) throws -> [UInt8] {
        assert(iterations >= 4 && iterations <= 32)
        let iterations = Int32(iterations)
        var salt = [Int8](repeating: 0, count: 64)
        if bcrypt_gensalt(iterations, &salt) != 0 {
            throw BCryptError.saltGenerationFailure
        }
        return salt.map { UInt8(bitPattern: $0) }
    }
}
