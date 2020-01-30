/*
Abstract:
Utilities for compact serialization of data structures for network transmission.
*/

import Foundation

public enum BitStreamError: Error {
    case tooShort
    case encodingError
}

public struct FloatCompressor {
    var minValue: Float
    var maxValue: Float
    var bits: Int
    private var maxBitValue: Double

    public init(minValue: Float, maxValue: Float, bits: Int) {
        self.minValue = minValue
        self.maxValue = maxValue
        self.bits = bits
        self.maxBitValue = pow(2.0, Double(bits)) - 1 // for 8 bits, highest value is 255, not 256
    }

    public func write(_ value: Float, to string: inout WritableBitStream) {
        let ratio = Double((value - minValue) / (maxValue - minValue))
        let clampedRatio = max(0.0, min(1.0, ratio))
        let bitPattern = UInt32(clampedRatio * maxBitValue)
        string.appendUInt32(bitPattern, numberOfBits: bits)
    }

    public func read(from string: inout ReadableBitStream) throws -> Float {
        let bitPattern = try string.readUInt32(numberOfBits: bits)

        let ratio = Float(Double(bitPattern) / maxBitValue)
        return  ratio * (maxValue - minValue) + minValue
    }

    #if canImport(CoreGraphics)
    import CoreGraphics
    func write(_ value: CGFloat, to string: inout WritableBitStream) {
        write(Float(value), to: &string)
    }
    
    func write(_ value: CGPoint, to string: inout WritableBitStream) {
        write(value.x, to: &string)
        write(value.y, to: &string)
    }
    
    func write(_ value: CGVector, to string: inout WritableBitStream) {
        write(value.dx, to: &string)
        write(value.dy, to: &string)
    }
    
    func write(_ value: SIMD2<Float>, to string: inout WritableBitStream) {
        write(value.x, to: &string)
        write(value.y, to: &string)
    }
    
    func write(_ value: SIMD3<Float>, to string: inout WritableBitStream) {
        write(value.x, to: &string)
        write(value.y, to: &string)
        write(value.z, to: &string)
    }
    
    func readCG(from string: inout ReadableBitStream) throws -> CGFloat {
        return CGFloat(try read(from: &string))
    }
    
    func readPoint(from string: inout ReadableBitStream) throws -> CGPoint {
        return CGPoint(x: try readCG(from: &string), y: try readCG(from: &string))
    }
    
    func readVector(from string: inout ReadableBitStream) throws -> CGVector {
        return CGVector(dx: try readCG(from: &string), dy: try readCG(from: &string))
    }
    
    func readFloat2(from string: inout ReadableBitStream) throws -> SIMD2<Float> {
        return SIMD2<Float>(x: try read(from: &string), y: try read(from: &string))
    }
    
    func readFloat3(from string: inout ReadableBitStream) throws -> SIMD3<Float> {
        return SIMD3<Float>(
            x: try read(from: &string),
            y: try read(from: &string),
            z: try read(from: &string))
    }
    #endif
    
}

/// Gets the number of bits required to encode an enum case.
public extension RawRepresentable where Self: CaseIterable, RawValue == UInt32 {
    static var bits: Int {
        let casesCount = UInt32(allCases.count)
        return UInt32.bitWidth - casesCount.leadingZeroBitCount
    }
}

public struct WritableBitStream {
    internal var bytes = [UInt8]()
    internal var endBitIndex = 0
    
    public init() {}
    // MARK: - Append

    public mutating func appendBool(_ value: Bool) {
        appendBit(UInt8(value ? 1 : 0))
    }

    public mutating func appendUInt32(_ value: UInt32) {
        appendUInt32(value, numberOfBits: value.bitWidth)
    }

    public mutating func appendUInt32(_ value: UInt32, numberOfBits: Int) {
        var tempValue = value
        for _ in 0..<numberOfBits {
            appendBit(UInt8(tempValue & 1))
            tempValue >>= 1
        }
    }
   
    // Appends an integer-based enum using the minimal number of bits for its set of possible cases.
    public mutating func appendEnum<T>(_ value: T) where T: CaseIterable & RawRepresentable, T.RawValue == UInt32 {
        appendUInt32(value.rawValue, numberOfBits: type(of: value).bits)
    }
    #if canImport(CoreGraphics)
    import CoreGraphics
    public mutating func appendCGFloat(_ value: CGFloat) {
        appendFloat(Float(value))
    }
    #endif
    
    public mutating func appendFloat(_ value: Float) {
        appendUInt32(value.bitPattern)
    }
    
    public mutating func append(_ value: Data) {
        align()
        let length = UInt32(value.count)
        appendUInt32(length)
        bytes.append(contentsOf: value)
        endBitIndex += Int(length * 8)
    }

    private mutating func appendBit(_ value: UInt8) {
        let bitShift = endBitIndex % 8
        let byteIndex = endBitIndex / 8
        if bitShift == 0 {
            bytes.append(UInt8(0))
        }

        bytes[byteIndex] |= UInt8(value << bitShift)
        endBitIndex += 1
    }

    private mutating func align() {
        // skip over any remaining bits in the current byte
        endBitIndex = bytes.count * 8
    }

    // MARK: - Pack/Unpack Data

    public func packData() -> Data {
        let endBitIndex32 = UInt32(endBitIndex)
        let endBitIndexBytes = [UInt8(truncatingIfNeeded: endBitIndex32),
                                UInt8(truncatingIfNeeded: endBitIndex32 >> 8),
                                UInt8(truncatingIfNeeded: endBitIndex32 >> 16),
                                UInt8(truncatingIfNeeded: endBitIndex32 >> 24)]
        return Data(endBitIndexBytes + bytes)
    }
}

public struct ReadableBitStream {
    var bytes = [UInt8]()
    var endBitIndex: Int
    var currentBit = 0
    var isAtEnd: Bool { return currentBit == endBitIndex }
    var header: UInt8
    
    public init?(data: Data) {
        var bytes = [UInt8](data)

        if bytes.count < 5 {
            print("Failed to initialize readable bit stream")
            return nil
        }

        self.header = bytes[0]
        bytes.remove(at: 0)
        
        var endBitIndex32 = UInt32(bytes[0])
        endBitIndex32 |= (UInt32(bytes[1]) << 8)
        endBitIndex32 |= (UInt32(bytes[2]) << 16)
        endBitIndex32 |= (UInt32(bytes[3]) << 24)
        endBitIndex = Int(endBitIndex32)

        bytes.removeSubrange(0...3)
        self.bytes = bytes
    }

    // MARK: - Read

    public mutating func readBool() throws -> Bool {
        if currentBit >= endBitIndex {
            throw BitStreamError.tooShort
        }
        return (readBit() > 0) ? true : false
    }

    
    #if canImport(CoreGraphics)
    import CoreGraphics
    public mutating func readCGFloat() throws -> CGFloat {
        return CGFloat(try readFloat())
    }
    #endif
    
    public mutating func readFloat() throws -> Float {
        var result: Float = 0.0
        do {
            result = try Float(bitPattern: readUInt32())
        } catch let error {
            throw error
        }
        return result
    }
    
    public mutating func readUInt32() throws -> UInt32 {
        var result: UInt32 = 0
        do {
            result = try readUInt32(numberOfBits: UInt32.bitWidth)
        } catch let error {
            throw error
        }
        return result
    }

    public mutating func readUInt32(numberOfBits: Int) throws -> UInt32 {
        if currentBit + numberOfBits > endBitIndex {
            throw BitStreamError.tooShort
        }

        var bitPattern: UInt32 = 0
        for index in 0..<numberOfBits {
            bitPattern |= (UInt32(readBit()) << index)
        }

        return bitPattern
    }

    public mutating func readData() throws -> Data {
        align()
        let length = Int(try readUInt32())
        assert(currentBit % 8 == 0)
        guard currentBit + (length * 8) <= endBitIndex else {
            throw BitStreamError.tooShort
        }
        let currentByte = currentBit / 8
        let endByte = currentByte + length

        let result = Data(bytes[currentByte..<endByte])
        currentBit += length * 8
        return result
    }

    private mutating func align() {
        let mod = currentBit % 8
        if mod != 0 {
            currentBit += 8 - mod
        }
    }

    private mutating func readBit() -> UInt8 {
        let bitShift = currentBit % 8
        let byteIndex = currentBit / 8
        currentBit += 1
        return (bytes[byteIndex] >> bitShift) & 1
    }
}
