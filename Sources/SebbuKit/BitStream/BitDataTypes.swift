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
public struct BitUnsigned<T: UnsignedInteger & FixedWidthInteger> {
    public var wrappedValue: T = 0
    public let bits: Int
    
    public init(bits: Int) {
        self.bits = bits
    }
    
    public init(maxValue: T) {
        bits = maxValue.bitWidth - maxValue.leadingZeroBitCount
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
    /// BitFloat encoding
    @inlinable
    mutating func append(_ value: BitFloat) {
        let floatCompressor = FloatCompressor(minValue: value.minValue, maxValue: value.maxValue, bits: value.bits)
        floatCompressor.write(value.wrappedValue, to: &self)
    }
    
    /// BitDouble encoding
    @inlinable
    mutating func append(_ value: BitDouble) {
        let doubleCompressor = DoubleCompressor(minValue: value.minValue, maxValue: value.maxValue, bits: value.bits)
        doubleCompressor.write(value.wrappedValue, to: &self)
    }
    
    @inlinable
    mutating func append(_ value: BitVector2<Float>) {
        let floatCompressor = FloatCompressor(minValue: value.minValue, maxValue: value.maxValue, bits: value.bits)
        floatCompressor.write(value.wrappedValue, to: &self)
    }

    @inlinable
    mutating func append(_ value: BitVector3<Float>) {
        let floatCompressor = FloatCompressor(minValue: value.minValue, maxValue: value.maxValue, bits: value.bits)
        floatCompressor.write(value.wrappedValue, to: &self)
    }
    
    @inlinable
    mutating func append(_ value: BitVector4<Float>) {
        let floatCompressor = FloatCompressor(minValue: value.minValue, maxValue: value.maxValue, bits: value.bits)
        floatCompressor.write(value.wrappedValue, to: &self)
    }
    
    @inlinable
    mutating func append(_ value: BitVector2<Double>) {
        let doubleCompressor = DoubleCompressor(minValue: value.minValue, maxValue: value.maxValue, bits: value.bits)
        doubleCompressor.write(value.wrappedValue, to: &self)
    }

    @inlinable
    mutating func append(_ value: BitVector3<Double>) {
        let doubleCompressor = DoubleCompressor(minValue: value.minValue, maxValue: value.maxValue, bits: value.bits)
        doubleCompressor.write(value.wrappedValue, to: &self)
    }
    
    @inlinable
    mutating func append(_ value: BitVector4<Double>) {
        let doubleCompressor = DoubleCompressor(minValue: value.minValue, maxValue: value.maxValue, bits: value.bits)
        doubleCompressor.write(value.wrappedValue, to: &self)
    }
    
    //TODO: BitMatrix2, BitMatrix3, BitMatrix4 encoding
    
    /// BitUnsigned encoding
    @inlinable
    @_specialize(where T == UInt8)
    @_specialize(where T == UInt16)
    @_specialize(where T == UInt32)
    @_specialize(where T == UInt64)
    @_specialize(where T == UInt)
    mutating func append<T>(_ value: BitUnsigned<T>) where T: UnsignedInteger {
        append(value.wrappedValue, numberOfBits: value.bits)
    }
    
    /// BitSigned encoding
    @inlinable
    mutating func append(_ value: BitSigned) {
        let intCompressor = IntCompressor(minValue: value.min, maxValue: value.max)
        intCompressor.write(value.wrappedValue, to: &self)
    }

    /// Generic BitStreamEncodable encoding
    @inlinable
    mutating func appendObject<T>(_ value: T) where T: BitStreamEncodable {
        value.encode(to: &self)
    }
    
    /// BitArray encoding
    @inlinable
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
    @inlinable
    static func << <T>(bitStream: inout WritableBitStream, value: BoundedArray<T>) where T: BitStreamCodable {
        bitStream.append(value)
    }
    
    @inlinable
    mutating func append<T>(_ value: BoundedArray<T>) where T: BitStreamCodable {
        append(UInt32(value.wrappedValue.count), numberOfBits: value.bits)
        for element in value.wrappedValue {
            element.encode(to: &self)
        }
    }
}

public extension ReadableBitStream {
    /// BitFloat decoding
    @inlinable
    mutating func read(_ value: inout BitFloat) throws {
        let floatCompressor = FloatCompressor(minValue: value.minValue, maxValue: value.maxValue, bits: value.bits)
        value.wrappedValue = try floatCompressor.read(from: &self)
    }
    
    /// BitDouble decoding
    @inlinable
    mutating func read(_ value: inout BitDouble) throws {
        let doubleCompressor = DoubleCompressor(minValue: value.minValue, maxValue: value.maxValue, bits: value.bits)
        value.wrappedValue = try doubleCompressor.read(from: &self)
    }
    
    @inlinable
    mutating func read(_ value: inout BitVector2<Float>) throws {
        let floatComperssor = FloatCompressor(minValue: value.minValue, maxValue: value.maxValue, bits: value.bits)
        value.wrappedValue = try floatComperssor.read(from: &self)
    }
    
    @inlinable
    mutating func read(_ value: inout BitVector3<Float>) throws {
        let floatComperssor = FloatCompressor(minValue: value.minValue, maxValue: value.maxValue, bits: value.bits)
        value.wrappedValue = try floatComperssor.read(from: &self)
    }
    
    @inlinable
    mutating func read(_ value: inout BitVector4<Float>) throws {
        let floatComperssor = FloatCompressor(minValue: value.minValue, maxValue: value.maxValue, bits: value.bits)
        value.wrappedValue = try floatComperssor.read(from: &self)
    }
    
    @inlinable
    mutating func read(_ value: inout BitVector2<Double>) throws {
        let doubleComperssor = DoubleCompressor(minValue: value.minValue, maxValue: value.maxValue, bits: value.bits)
        value.wrappedValue = try doubleComperssor.read(from: &self)
    }
    
    @inlinable
    mutating func read(_ value: inout BitVector3<Double>) throws {
        let doubleComperssor = DoubleCompressor(minValue: value.minValue, maxValue: value.maxValue, bits: value.bits)
        value.wrappedValue = try doubleComperssor.read(from: &self)
    }
    
    @inlinable
    mutating func read(_ value: inout BitVector4<Double>) throws {
        let doubleComperssor = DoubleCompressor(minValue: value.minValue, maxValue: value.maxValue, bits: value.bits)
        value.wrappedValue = try doubleComperssor.read(from: &self)
    }
    
    //TODO: BitMatrix2, BitMatrix3, BitMatrix4 decoding
    
    /// BitUnsigned decoding
    @inlinable
    @_specialize(where T == UInt8)
    @_specialize(where T == UInt16)
    @_specialize(where T == UInt32)
    @_specialize(where T == UInt64)
    @_specialize(where T == UInt)
    mutating func read<T>(_ value: inout BitUnsigned<T>) throws where T: UnsignedInteger {
        value.wrappedValue = try self.read(numberOfBits: value.bits)
    }
    
    /// BitSigned decoding
    @inlinable
    mutating func read(_ value: inout BitSigned) throws {
        let intCompressor = IntCompressor(minValue: value.min, maxValue: value.max)
        value.wrappedValue = try intCompressor.read(from: &self)
    }
    
    /// Generic BitStreamDecodable decoding
    @inlinable
    mutating func readObject<T>() throws -> T where T: BitStreamCodable {
        return try T(from: &self)
    }
    
    /// Array with chosen bit value for count decoding
    @inlinable
    @_specialize(where T == UInt8)
    @_specialize(where T == UInt16)
    @_specialize(where T == UInt32)
    @_specialize(where T == UInt64)
    @_specialize(where T == UInt)
    mutating func read<T>(_ value: inout BitArray<T>) throws where T: UnsignedInteger {
        let count = Int(try self.read(numberOfBits: value.bits) as UInt32)
        value.wrappedValue.removeAll(keepingCapacity: true)
        value.wrappedValue.reserveCapacity(count)
        for _ in 0..<count {
            value.wrappedValue.append(try self.read(numberOfBits: value.valueBits))
        }
    }
    
    /// Array with chosen bit value for count count decoding, generic
    @inlinable
    mutating func read<T>(_ value: inout BoundedArray<T>) throws where T: BitStreamCodable {
        let count = Int(try self.read(numberOfBits: value.bits) as UInt32)
        value.wrappedValue.removeAll(keepingCapacity: true)
        value.wrappedValue.reserveCapacity(count)
        for _ in 0..<count {
            value.wrappedValue.append(try T(from: &self))
        }
    }
}

