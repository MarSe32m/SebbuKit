//
//  HMAC.swift
//  
//
//  Created by Sebastian Toivonen on 30.7.2021.
//

import Crypto

@inlinable
public func HMACSHA256Signature(_ data: [UInt8], key: SymmetricKey) -> [UInt8] {
    let signature = HMAC<SHA256>.authenticationCode(for: data, using: key)
    return [UInt8](signature)
}

@inlinable
public func HMACSHA256Verify(_ data: [UInt8], signature: [UInt8], key: SymmetricKey) -> Bool {
    HMAC<SHA256>.isValidAuthenticationCode(signature, authenticating: data, using: key)
}

@inlinable
public func HMACSHA512Signature(_ data: [UInt8], key: SymmetricKey) -> [UInt8] {
    let signature = HMAC<SHA512>.authenticationCode(for: data, using: key)
    return [UInt8](signature)
}

@inlinable
public func HMACSHA512Verify(_ data: [UInt8], signature: [UInt8], key: SymmetricKey) -> Bool {
    HMAC<SHA512>.isValidAuthenticationCode(signature, authenticating: data, using: key)
}

#if canImport(Foundation)
import Foundation

@inlinable
public func HMACSHA256Signature(_ data: Data, key: SymmetricKey) -> Data {
    let signature = HMAC<SHA256>.authenticationCode(for: data, using: key)
    return Data(signature)
}

@inlinable
public func HMACSHA256Verify(_ data: Data, signature: Data, key: SymmetricKey) -> Bool {
    HMAC<SHA256>.isValidAuthenticationCode(signature, authenticating: data, using: key)
}

@inlinable
public func HMACSHA512Signature(_ data: Data, key: SymmetricKey) -> Data {
    let signature = HMAC<SHA512>.authenticationCode(for: data, using: key)
    return Data(signature)
}

@inlinable
public func HMACSHA512Verify(_ data: Data, signature: Data, key: SymmetricKey) -> Bool {
    HMAC<SHA512>.isValidAuthenticationCode(signature, authenticating: data, using: key)
}
#endif
