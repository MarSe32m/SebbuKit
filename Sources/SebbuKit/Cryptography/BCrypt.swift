//
//  BCrypt.swift
//  
//  Created by Sebastian Toivonen on 30.7.2021.

import bcrypt

public final class BCrypt {
    public init() { }

    @inlinable
    public static func hash(_ plaintext: String, cost: Int = 12) throws -> String {
        try BCrypt().hash(plaintext, cost: cost)
    }
    
    public func hash(_ plaintext: String, cost: Int = 12) throws -> String {
        guard cost >= BCRYPT_MINLOGROUNDS && cost <= 31 else {
            throw BcryptError.invalidCost
        }
        return try self.hash(plaintext, salt: self.generateSalt(cost: cost))
    }

    @inlinable
    public static func hash(_ plaintext: String, salt: String) throws -> String {
        try BCrypt().hash(plaintext, salt: salt)
    }
    
    public func hash(_ plaintext: String, salt: String) throws -> String {
        guard isSaltValid(salt) else {
            throw BcryptError.invalidSalt
        }

        let originalAlgorithm: Algorithm
        if salt.count == Algorithm.saltCount {
            originalAlgorithm = ._2b
        } else {
            let revisionString = String(salt.prefix(4))
            if let parsedRevision = Algorithm(rawValue: revisionString) {
                originalAlgorithm = parsedRevision
            } else {
                throw BcryptError.invalidSalt
            }
        }

        let normalizedSalt: String
        if originalAlgorithm == Algorithm._2y {
            normalizedSalt = Algorithm._2b.rawValue + salt.dropFirst(originalAlgorithm.revisionCount)
        } else {
            normalizedSalt = salt
        }

        let hashedBytes = UnsafeMutablePointer<Int8>.allocate(capacity: 128)
        defer { hashedBytes.deallocate() }
        let hashingResult = bcrypt_hashpass(
            plaintext,
            normalizedSalt,
            hashedBytes,
            128
        )

        guard hashingResult == 0 else {
            throw BcryptError.hashFailure
        }
        return originalAlgorithm.rawValue
            + String(cString: hashedBytes)
                .dropFirst(originalAlgorithm.revisionCount)
    }

    
    @inlinable
    public static func verify(_ plaintext: String, created hash: String) throws -> Bool {
        try BCrypt().verify(plaintext, created: hash)
    }
    
    public func verify(_ plaintext: String, created hash: String) throws -> Bool {
        guard let hashVersion = Algorithm(rawValue: String(hash.prefix(4))) else {
            throw BcryptError.invalidHash
        }

        let hashSalt = String(hash.prefix(hashVersion.fullSaltCount))
        guard !hashSalt.isEmpty, hashSalt.count == hashVersion.fullSaltCount else {
            throw BcryptError.invalidHash
        }

        let hashChecksum = String(hash.suffix(hashVersion.checksumCount))
        guard !hashChecksum.isEmpty, hashChecksum.count == hashVersion.checksumCount else {
            throw BcryptError.invalidHash
        }

        let messageHash = try self.hash(plaintext, salt: hashSalt)
        let messageHashChecksum = String(messageHash.suffix(hashVersion.checksumCount))
        return messageHashChecksum.slowCompare(to: hashChecksum)
    }

    private func generateSalt(cost: Int, algorithm: Algorithm = ._2b, seed: [UInt8]? = nil) -> String {
        let randomData: [UInt8]
        if let seed = seed {
            randomData = seed
        } else {
            randomData = [UInt8].random(count: 16)
        }
        let encodedSalt = base64Encode(randomData)

        return
            algorithm.rawValue +
            (cost < 10 ? "0\(cost)" : "\(cost)" ) + // 0 padded
            "$" +
            encodedSalt
    }

    private func isSaltValid(_ salt: String) -> Bool {
        let revisionString = String(salt.prefix(4))
        if let algorithm = Algorithm(rawValue: revisionString) {
            return salt.count == algorithm.fullSaltCount
        } else {
            return salt.count == Algorithm.saltCount
        }
    }

    private func base64Encode(_ data: [UInt8]) -> String {
        let encodedBytes = UnsafeMutablePointer<Int8>.allocate(capacity: 25)
        defer { encodedBytes.deallocate() }
        let res = data.withUnsafeBytes { bytes in
            encode_base64(encodedBytes, bytes.baseAddress?.assumingMemoryBound(to: UInt8.self), bytes.count)
        }
        assert(res == 0, "base64 convert failed")
        return String(cString: encodedBytes)
    }

    private enum Algorithm: String, RawRepresentable {
        case _2a = "$2a$"
        case _2y = "$2y$"
        case _2b = "$2b$"

        var revisionCount: Int {
            return 4
        }

        var fullSaltCount: Int {
            return 29
        }

        var checksumCount: Int {
            return 31
        }

        static var saltCount: Int {
            return 22
        }
    }
}

public enum BcryptError: Swift.Error, CustomStringConvertible, LocalizedError {
    case invalidCost
    case invalidSalt
    case hashFailure
    case invalidHash

    public var errorDescription: String? {
        return self.description
    }

    public var description: String {
        return "Bcrypt error: \(self.reason)"
    }

    var reason: String {
        switch self {
        case .invalidCost:
            return "Cost should be between 4 and 31"
        case .invalidSalt:
            return "Provided salt has the incorrect format"
        case .hashFailure:
            return "Unable to compute hash"
        case .invalidHash:
            return "Invalid hash formatting"
        }
    }
}

extension Collection where Element: Equatable {
    public func slowCompare<C>(to other: C) -> Bool where C: Collection, C.Element == Element {
        let chk = self
        let sig = other

        var match = true
        for i in 0..<Swift.min(chk.count, sig.count) {
            if chk[chk.index(chk.startIndex, offsetBy: i)] != sig[sig.index(sig.startIndex, offsetBy: i)] {
                match = false
            }
        }

        if chk.count == sig.count {
            return match
        } else {
            return false
        }
    }
}
