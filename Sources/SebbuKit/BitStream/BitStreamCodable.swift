//
//  BitStreamCodable.swift
//
//  Created by Sebastian Toivonen on 24.12.2019.
//  Copyright © 2020 Sebastian Toivonen. All rights reserved.

import Foundation

public protocol BitStreamEncodable {
    func encode(to bitStream: inout WritableBitStream) throws
}

public protocol BitStreamDecodable {
    init(from bitStream: inout ReadableBitStream) throws
}

/// - Tag: BitStreamCodable
public typealias BitStreamCodable = BitStreamEncodable & BitStreamDecodable

public extension BitStreamEncodable where Self: Encodable {
    func encode(to bitStream: inout WritableBitStream) throws {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        let data = try encoder.encode(self)
        bitStream.append(data)
    }
}

public extension BitStreamDecodable where Self: Decodable {
    init(from bitStream: inout ReadableBitStream) throws {
        let data = try bitStream.readData()
        let decoder = PropertyListDecoder()
        self = try decoder.decode(Self.self, from: data)
    }
}

extension String: BitStreamCodable {
    public init(from bitStream: inout ReadableBitStream) throws {
        let data = try bitStream.readData()
        if let value = String(data: data, encoding: .utf8) {
            self = value
        } else {
            throw BitStreamError.encodingError
        }
    }

    public func encode(to bitStream: inout WritableBitStream) throws {
        if let data = data(using: .utf8) {
            bitStream.append(data)
        } else {
            throw BitStreamError.encodingError
        }
    }
}

extension UInt32: BitStreamCodable {
    init?(from bitStream: inout ReadableBitStream, numberOfBits: Int) {
        do {
            self = try bitStream.readUInt32(numberOfBits: numberOfBits)
        } catch let error {
            print("Error decoding UInt32 with \(numberOfBits) bits")
            print(error)
            return nil
        }
    }
    
    public init(from bitStream: inout ReadableBitStream) throws {
        self = try bitStream.readUInt32()
    }
    
    func encode(to bitStream: inout WritableBitStream, numberOfBits: Int) -> Bool {
        bitStream.appendUInt32(self, numberOfBits: numberOfBits)
        return true
    }
    
    public func encode(to bitStream: inout WritableBitStream) throws {
        bitStream.appendUInt32(self)
    }
}

extension Float: BitStreamCodable {
    public init(from bitStream: inout ReadableBitStream) throws {
        self = try bitStream.readFloat()
    }
    
    public func encode(to bitStream: inout WritableBitStream) throws {
        bitStream.appendFloat(self)
    }
}


#if canImport(CoreGraphics)
import CoreGraphics
extension CGFloat: BitStreamCodable {
    public init(from bitStream: inout ReadableBitStream) throws {
        self = try bitStream.readCGFloat()
    }
    
    public func encode(to bitStream: inout WritableBitStream) throws {
        bitStream.appendCGFloat(self)
    }
}
#endif
