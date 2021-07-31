//
//  AES.swift
//  
//
//  Created by Sebastian Toivonen on 30.7.2021.
//

import Crypto

@inline(__always)
public func encryptAES(_ input: [UInt8], key: SymmetricKey) throws -> [UInt8]? {
    let sealedBox = try AES.GCM.seal(input, using: key)
    if let combined = sealedBox.combined {
        return [UInt8](combined)
    }
    return nil
}

@inline(__always)
public func decryptAES(_ input: [UInt8], key: SymmetricKey) throws -> [UInt8] {
    let box = try AES.GCM.SealedBox(combined: input)
    return try [UInt8](AES.GCM.open(box, using: key))
}

#if canImport(Foundation)
import Foundation

@inline(__always)
public func encryptAES(_ input: Data, key: SymmetricKey) throws -> Data? {
    try AES.GCM.seal(input, using: key).combined
}

@inline(__always)
public func decryptAES(_ input: Data, key: SymmetricKey) throws -> Data {
    let box = try AES.GCM.SealedBox(combined: input)
    return try AES.GCM.open(box, using: key)
}
#endif
