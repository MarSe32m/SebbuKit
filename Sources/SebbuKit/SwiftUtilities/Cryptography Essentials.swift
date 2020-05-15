//
//  Cryptography Essentials.swift
//  
//
//  Created by Sebastian Toivonen on 15.5.2020.
//

import Foundation
import Crypto

@inlinable
func encrypt(input: [UInt8], key: SymmetricKey) throws -> Data? {
    let sealedBox = try AES.GCM.seal(input, using: key)
    return sealedBox.combined
}

@inlinable
func decrypt(input: Data, key: SymmetricKey) throws -> Data {
    let k = try AES.GCM.SealedBox(combined: input)
    return try AES.GCM.open(k, using: key)
}
