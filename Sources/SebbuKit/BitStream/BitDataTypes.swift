//
//  BitDataTypes.swift
//  
//
//  Created by Sebastian Toivonen on 29.5.2021.
//
//  Copyright © 2021 Sebastian Toivonen. All rights reserved.
import Foundation
import GLMSwift

@propertyWrapper
public struct BitUnsigned<T: UnsignedInteger> {
    public var wrappedValue: T = 0
    public let bits: Int
    
    public init(bits: Int) {
        self.bits = bits
    }
}

@propertyWrapper
public struct BitSigned {
    public var wrappedValue: Int = 0
    public let min: Int
    public let max: Int
    
    public init(min: Int, max: Int) {
        self.min = min
        self.max = max
    }
}

@propertyWrapper
public struct BitFloat {
    public var wrappedValue: Float = 0
    public let minValue: Float
    public let maxValue: Float
    public let bits: Int
    
    public init(min: Float, max: Float, bits: Int) {
        self.minValue = min
        self.maxValue = max
        self.bits = bits
    }
}

@propertyWrapper
public struct BitDouble {
    public var wrappedValue: Double = 0
    public let minValue: Double
    public let maxValue: Double
    public let bits: Int
    
    public init(min: Double, max: Double, bits: Int) {
        self.minValue = min
        self.maxValue = max
        self.bits = bits
    }
}

@propertyWrapper
public struct BitVector2<T: BinaryFloatingPoint & SIMDScalar> {
    public var wrappedValue: Vector2<T> = Vector2(x: 0, y: 0)
    public let minValue: T
    public let maxValue: T
    public let bits: Int
    
    public init(minValue: T, maxValue: T, bits: Int) {
        self.minValue = minValue
        self.maxValue = maxValue
        self.bits = bits
    }
}

@propertyWrapper
public struct BitVector3<T: BinaryFloatingPoint & SIMDScalar> {
    public var wrappedValue: Vector3<T> = Vector3(x: 0, y: 0)
    public let minValue: T
    public let maxValue: T
    public let bits: Int
    
    public init(minValue: T, maxValue: T, bits: Int) {
        self.minValue = minValue
        self.maxValue = maxValue
        self.bits = bits
    }
}

@propertyWrapper
public struct BitVector4<T: BinaryFloatingPoint & SIMDScalar> {
    public var wrappedValue: Vector4<T> = Vector4(x: 0, y: 0)
    public let minValue: T
    public let maxValue: T
    public let bits: Int
    
    public init(minValue: T, maxValue: T, bits: Int) {
        self.minValue = minValue
        self.maxValue = maxValue
        self.bits = bits
    }
}

//TODO: BitMatrix2, BitMatrix3, BitMatrix4

@propertyWrapper
public struct BitArray<Value> where Value: UnsignedInteger {
    public var wrappedValue: Array<Value> = []
    public let bits: Int
    public let valueBits: Int
    
    public init(maxCount: UInt, valueBits: Int) {
        bits = UInt64.bitWidth - maxCount.leadingZeroBitCount
        self.valueBits = valueBits
    }
}

@propertyWrapper
public struct BoundedArray<Value> where Value: BitStreamCodable {
    public var wrappedValue: Array<Value> = []
    public let bits: Int
    
    public init(maxCount: UInt) {
        bits = UInt64.bitWidth - maxCount.leadingZeroBitCount
    }
}

public extension WritableBitStream {
    /// Boolean encoding
    @inline(__always)
    static func << (bitStream: inout WritableBitStream, value: Bool) {
        bitStream.append(value)
    }
    
    /// Enum encoding
    @inline(__always)
    static func << <T>(bitStream: inout WritableBitStream, value: T) where T: CaseIterable & RawRepresentable, T.RawValue == UInt32 {
        bitStream.append(value)
    }
    
    /// BitFloat encoding
    @inline(__always)
    static func << (bitStream: inout WritableBitStream, value: BitFloat) {
        bitStream.append(value)
    }
    
    @inline(__always)
    mutating func append(_ value: BitFloat) {
        let floatCompressor = FloatCompressor(minValue: value.minValue, maxValue: value.maxValue, bits: value.bits)
        floatCompressor.write(value.wrappedValue, to: &self)
    }
    
    /// BitDouble encoding
    @inline(__always)
    static func << (bitStream: inout WritableBitStream, value: BitDouble) {
        bitStream.append(value)
    }
    
    @inline(__always)
    mutating func append(_ value: BitDouble) {
        let doubleCompressor = DoubleCompressor(minValue: value.minValue, maxValue: value.maxValue, bits: value.bits)
        doubleCompressor.write(value.wrappedValue, to: &self)
    }

    
    @inline(__always)
    static func << (bitStream: inout WritableBitStream, value: BitVector2<Float>) {
        let floatCompressor = FloatCompressor(minValue: value.minValue, maxValue: value.maxValue, bits: value.bits)
        floatCompressor.write(value.wrappedValue, to: &bitStream)
    }

    @inline(__always)
    static func << (bitStream: inout WritableBitStream, value: BitVector3<Float>) {
        let floatCompressor = FloatCompressor(minValue: value.minValue, maxValue: value.maxValue, bits: value.bits)
        floatCompressor.write(value.wrappedValue, to: &bitStream)
    }
    
    @inline(__always)
    static func << (bitStream: inout WritableBitStream, value: BitVector4<Float>) {
        let floatCompressor = FloatCompressor(minValue: value.minValue, maxValue: value.maxValue, bits: value.bits)
        floatCompressor.write(value.wrappedValue, to: &bitStream)
    }
    
    @inline(__always)
    static func << (bitStream: inout WritableBitStream, value: BitVector2<Double>) {
        let doubleCompressor = DoubleCompressor(minValue: value.minValue, maxValue: value.maxValue, bits: value.bits)
        doubleCompressor.write(value.wrappedValue, to: &bitStream)
    }

    @inline(__always)
    static func << (bitStream: inout WritableBitStream, value: BitVector3<Double>) {
        let doubleCompressor = DoubleCompressor(minValue: value.minValue, maxValue: value.maxValue, bits: value.bits)
        doubleCompressor.write(value.wrappedValue, to: &bitStream)
    }
    
    @inline(__always)
    static func << (bitStream: inout WritableBitStream, value: BitVector4<Double>) {
        let doubleCompressor = DoubleCompressor(minValue: value.minValue, maxValue: value.maxValue, bits: value.bits)
        doubleCompressor.write(value.wrappedValue, to: &bitStream)
    }
    
    //TODO: BitMatrix2, BitMatrix3, BitMatrix4 encoding
    
    /// BitUnsigned encoding
    @inline(__always)
    @_specialize(where T == UInt8)
    @_specialize(where T == UInt16)
    @_specialize(where T == UInt32)
    @_specialize(where T == UInt64)
    @_specialize(where T == UInt)
    static func << <T> (bitStream: inout WritableBitStream, value: BitUnsigned<T>) where T: UnsignedInteger {
        bitStream.append(value)
    }
    
    
    @inline(__always)
    @_specialize(where T == UInt8)
    @_specialize(where T == UInt16)
    @_specialize(where T == UInt32)
    @_specialize(where T == UInt64)
    @_specialize(where T == UInt)
    mutating func append<T>(_ value: BitUnsigned<T>) where T: UnsignedInteger {
        append(value.wrappedValue, numberOfBits: value.bits)
    }
    
    /// BitSigned encoding
    @inline(__always)
    static func << (bitStream: inout WritableBitStream, value: BitSigned) {
        bitStream.append(value)
    }
    
    @inline(__always)
    mutating func append(_ value: BitSigned) {
        let intCompressor = IntCompressor(minValue: value.min, maxValue: value.max)
        intCompressor.write(value.wrappedValue, to: &self)
    }
    
    /// Generic BitStreamEncodable encoding
    @inline(__always)
    static func << (bitStream: inout WritableBitStream, value: BitStreamEncodable) {
        value.encode(to: &bitStream)
    }

    /// Generic BitStreamEncodable encoding
    @inline(__always)
    mutating func appendObject<T>(_ value: T) where T: BitStreamEncodable {
        value.encode(to: &self)
    }
    
    /// Bytes encoding
    @inline(__always)
    static func << (bitStream: inout WritableBitStream, value: [UInt8]) {
        bitStream.append(value)
    }
    
    /// BitArray encoding
    @inline(__always)
    @_specialize(where T == UInt8)
    @_specialize(where T == UInt16)
    @_specialize(where T == UInt32)
    @_specialize(where T == UInt64)
    @_specialize(where T == UInt)
    static func << <T>(bitStream: inout WritableBitStream, value: BitArray<T>) where T: UnsignedInteger {
        bitStream.append(value)
    }
    
    @inline(__always)
    @_specialize(where T == UInt8)
    @_specialize(where T == UInt16)
    @_specialize(where T == UInt32)
    @_specialize(where T == UInt64)
    @_specialize(where T == UInt)
    mutating func append<T>(_ value: BitArray<T>) where T: UnsignedInteger {
        append(UInt32(value.wrappedValue.count), numberOfBits: value.bits)
        for element in value.wrappedValue {
            append(element, numberOfBits: value.valueBits)
        }
    }
    
    /// BoundedArray encoding
    @inline(__always)
    static func << <T>(bitStream: inout WritableBitStream, value: BoundedArray<T>) where T: BitStreamCodable {
        bitStream.append(value)
    }
    
    @inline(__always)
    mutating func append<T>(_ value: BoundedArray<T>) where T: BitStreamCodable {
        append(UInt32(value.wrappedValue.count), numberOfBits: value.bits)
        for element in value.wrappedValue {
            element.encode(to: &self)
        }
    }
}

public extension ReadableBitStream {
    /// Boolean decoding
    @inline(__always)
    static func >> (bitStream: inout ReadableBitStream, value: inout Bool) throws {
        value = try bitStream.read()
    }
    
    /// Enum decoding
    @inline(__always)
    static func >> <T>(bitStream: inout ReadableBitStream, value: inout T) throws where T: CaseIterable & RawRepresentable, T.RawValue == UInt32 {
        value = try bitStream.read()
    }
    
    /// BitFloat decoding
    @inline(__always)
    static func >> (bitStream: inout ReadableBitStream, value: inout BitFloat) throws {
        let floatCompressor = FloatCompressor(minValue: value.minValue, maxValue: value.maxValue, bits: value.bits)
        value.wrappedValue = try floatCompressor.read(from: &bitStream)
    }
    
    /// BitDouble decoding
    @inline(__always)
    static func >> (bitStream: inout ReadableBitStream, value: inout BitDouble) throws {
        let doubleCompressor = DoubleCompressor(minValue: value.minValue, maxValue: value.maxValue, bits: value.bits)
        value.wrappedValue = try doubleCompressor.read(from: &bitStream)
    }
    
    //TODO: Implement for your own math types
    #if canImport(VectorMath)
    /// BitVector2 decoding
    @inline(__always)
    static func >> (bitStream: inout ReadableBitStream, value: inout BitVector2) throws {
        let floatCompressor = FloatCompressor(minValue: value.minValue, maxValue: value.maxValue, bits: value.bits)
        value.wrappedValue = try floatCompressor.readVector2(from: &bitStream)
    }
    #endif
    
    @inline(__always)
    static func >> (bitStream: inout ReadableBitStream, value: inout BitVector2<Float>) throws {
        let floatComperssor = FloatCompressor(minValue: value.minValue, maxValue: value.maxValue, bits: value.bits)
        value.wrappedValue = try floatComperssor.read(from: &bitStream)
    }
    
    @inline(__always)
    static func >> (bitStream: inout ReadableBitStream, value: inout BitVector3<Float>) throws {
        let floatComperssor = FloatCompressor(minValue: value.minValue, maxValue: value.maxValue, bits: value.bits)
        value.wrappedValue = try floatComperssor.read(from: &bitStream)
    }
    
    @inline(__always)
    static func >> (bitStream: inout ReadableBitStream, value: inout BitVector4<Float>) throws {
        let floatComperssor = FloatCompressor(minValue: value.minValue, maxValue: value.maxValue, bits: value.bits)
        value.wrappedValue = try floatComperssor.read(from: &bitStream)
    }
    
    @inline(__always)
    static func >> (bitStream: inout ReadableBitStream, value: inout BitVector2<Double>) throws {
        let doubleCompressor = DoubleCompressor(minValue: value.minValue, maxValue: value.maxValue, bits: value.bits)
        value.wrappedValue = try doubleCompressor.read(from: &bitStream)
    }
    
    @inline(__always)
    static func >> (bitStream: inout ReadableBitStream, value: inout BitVector3<Double>) throws {
        let doubleCompressor = DoubleCompressor(minValue: value.minValue, maxValue: value.maxValue, bits: value.bits)
        value.wrappedValue = try doubleCompressor.read(from: &bitStream)
    }
    
    @inline(__always)
    static func >> (bitStream: inout ReadableBitStream, value: inout BitVector4<Double>) throws {
        let doubleCompressor = DoubleCompressor(minValue: value.minValue, maxValue: value.maxValue, bits: value.bits)
        value.wrappedValue = try doubleCompressor.read(from: &bitStream)
    }
    
    //TODO: BitMatrix2, BitMatrix3, BitMatrix4 decoding
    
    /// BitUnsigned decoding
    @inline(__always)
    @_specialize(where T == UInt8)
    @_specialize(where T == UInt16)
    @_specialize(where T == UInt32)
    @_specialize(where T == UInt64)
    @_specialize(where T == UInt)
    static func >> <T> (bitStream: inout ReadableBitStream, value: inout BitUnsigned<T>) throws where T: UnsignedInteger {
        value.wrappedValue = try bitStream.read(numberOfBits: value.bits)
    }
    
    /// BitSigned decoding
    @inline(__always)
    static func >> (bitStream: inout ReadableBitStream, value: inout BitSigned) throws {
        let intCompressor = IntCompressor(minValue: value.min, maxValue: value.max)
        value.wrappedValue = try intCompressor.read(from: &bitStream)
    }
    
    /// Generic BitStreamDecodable decoding
    @inline(__always)
    mutating func readObject<T>(_ type: T.Type) throws -> T where T: BitStreamDecodable {
        return try T.init(from: &self)
    }
    
    /// Generic BitStreamCodable type decoding
    @inline(__always)
    static func >> <T>(bitStream: inout ReadableBitStream, type: T.Type) throws -> T where T: BitStreamDecodable {
        return try T.init(from: &bitStream)
    }
    
    /// Bytes decoding
    @inline(__always)
    static func >> (bitStream: inout ReadableBitStream, value: [UInt8].Type) throws -> [UInt8] {
        return try bitStream.read()
    }
    
    /// Array with chosen bit value for count decoding
    @inline(__always)
    @_specialize(where T == UInt8)
    @_specialize(where T == UInt16)
    @_specialize(where T == UInt32)
    @_specialize(where T == UInt64)
    @_specialize(where T == UInt)
    static func >> <T>(bitStream: inout ReadableBitStream, value: inout BitArray<T>) throws where T: UnsignedInteger {
        let count = Int(try bitStream.read(numberOfBits: value.bits) as UInt32)
        value.wrappedValue.removeAll(keepingCapacity: true)
        value.wrappedValue.reserveCapacity(count)
        for _ in 0..<count {
            value.wrappedValue.append(try bitStream.read(numberOfBits: value.valueBits))
        }
    }
    
    /// Array with chosen bit value for count count decoding, generic
    static func >> <T>(bitStream: inout ReadableBitStream, value: inout BoundedArray<T>) throws where T: BitStreamCodable {
        let count = Int(try bitStream.read(numberOfBits: value.bits) as UInt32)
        value.wrappedValue.removeAll(keepingCapacity: true)
        value.wrappedValue.reserveCapacity(count)
        for _ in 0..<count {
            value.wrappedValue.append(try T.init(from: &bitStream))
        }
    }
}

