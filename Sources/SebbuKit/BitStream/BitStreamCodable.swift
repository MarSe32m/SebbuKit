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

@propertyWrapper
public struct BitFloat {
    public var wrappedValue: Float = 0
    public let minValue: Float
    public let maxValue: Float
    public let bits: Int
    
    public init(minValue: Float, maxValue: Float, bits: Int) {
        self.minValue = minValue
        self.maxValue = maxValue
        self.bits = bits
    }
}

@propertyWrapper
public struct BitVector2 {
    public var wrappedValue: Vector2 = .zero
    public let minValue: Float
    public let maxValue: Float
    public let bits: Int
    
    public init(minValue: Float, maxValue: Float, bits: Int) {
        self.minValue = minValue
        self.maxValue = maxValue
        self.bits = bits
    }
}

@propertyWrapper
public struct BitUnsigned {
    public var wrappedValue: UInt32 = 0
    public let bits: Int
    
    public init(bits: Int = 32) {
        self.bits = bits
    }
}

@propertyWrapper
public struct BitArray<Value> where Value: BitStreamCodable {
    public var wrappedValue: Array<Value> = []
    public let bits: Int
    
    public init(bits: Int) {
        self.bits = bits
    }
}

public extension WritableBitStream {
    
    /// Boolean encoding
    @inlinable
    static func << (bitStream: inout WritableBitStream, value: Bool) {
        bitStream.appendBool(value)
    }
    
    /// Enum encoding
    @inlinable
    static func << <T>(bitStream: inout WritableBitStream, value: T) where T: CaseIterable & RawRepresentable, T.RawValue == UInt32 {
        bitStream.appendEnum(value)
    }
    
    /// BitFloat encoding
    @inlinable
    static func << (bitStream: inout WritableBitStream, value: BitFloat) {
        let floatCompressor = FloatCompressor(minValue: value.minValue, maxValue: value.maxValue, bits: value.bits)
        floatCompressor.write(value.wrappedValue, to: &bitStream)
    }
    
    /// BitVector2 encoding
    @inlinable
    static func << (bitStream: inout WritableBitStream, value: BitVector2) {
        let floatCompressor = FloatCompressor(minValue: value.minValue, maxValue: value.maxValue, bits: value.bits)
        floatCompressor.write(value.wrappedValue, to: &bitStream)
    }
    
    /// BitUnsigned encoding
    @inlinable
    static func << (bitStream: inout WritableBitStream, value: BitUnsigned) {
        bitStream.appendUInt32(value.wrappedValue, numberOfBits: value.bits)
    }
    
    /// Generic BitStreamEncodable encoding
    @inlinable
    static func << (bitStream: inout WritableBitStream, value: BitStreamEncodable) throws {
        try value.encode(to: &bitStream)
    }
    
    /// Data encoding
    @inlinable
    static func << (bitStream: inout WritableBitStream, value: Data) throws {
        bitStream.append(value)
    }
    
    /// BitArray with chosen bit value for count encoding
    @inlinable
    static func << <T>(bitStream: inout WritableBitStream, value: BitArray<T>) throws where T: BitStreamCodable {
        bitStream.appendUInt32(UInt32(value.wrappedValue.count), numberOfBits: value.bits)
        for element in value.wrappedValue {
            try bitStream << element
        }
    }
}

public extension ReadableBitStream {
    /// Boolean decoding
    @inlinable
    static func >> (bitStream: inout ReadableBitStream, value: Bool.Type) throws -> Bool {
        return try bitStream.readBool()
    }
    
    /// Enum decoding
    @inlinable
    static func >> <T>(bitStream: inout ReadableBitStream, value: T.Type) throws -> T where T: CaseIterable & RawRepresentable, T.RawValue == UInt32 {
        try bitStream.readEnum()
    }
    
    /// BitFloat decoding
    @inlinable
    static func >> (bitStream: inout ReadableBitStream, value: inout BitFloat) throws {
        let floatCompressor = FloatCompressor(minValue: value.minValue, maxValue: value.maxValue, bits: value.bits)
        value.wrappedValue = try floatCompressor.read(from: &bitStream)
    }
    
    /// BitVector2 decoding
    @inlinable
    static func >> (bitStream: inout ReadableBitStream, value: inout BitVector2) throws {
        let floatCompressor = FloatCompressor(minValue: value.minValue, maxValue: value.maxValue, bits: value.bits)
        value.wrappedValue = try floatCompressor.readVector2(from: &bitStream)
    }
    
    /// BitUnsigned decoding
    @inlinable
    static func >> (bitStream: inout ReadableBitStream, value: inout BitUnsigned) throws {
        value.wrappedValue = try bitStream.readUInt32(numberOfBits: value.bits)
    }
    
    /// Generic BitStreamCodable type decoding
    @inlinable
    static func >> <T>(bitStream: inout ReadableBitStream, value: T.Type) throws -> T where T: BitStreamDecodable {
        return try T.init(from: &bitStream)
    }
    
    /// Data decoding
    @inlinable
    static func >> (bitStream: inout ReadableBitStream, value: Data.Type) throws  -> Data {
        return try bitStream.readData()
    }
    
    /// Array with chosen bit value for count decoding
    @inlinable
    static func >> <T>(bitStream: inout ReadableBitStream, value: inout BitArray<T>) throws where T: BitStreamCodable {
        let count = Int(try bitStream.readUInt32(numberOfBits: value.bits))
        value.wrappedValue.removeAll(keepingCapacity: true)
        for _ in 0..<count {
            value.wrappedValue.append(try bitStream >> T.self)
        }
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
