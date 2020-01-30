/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Protocols for defining types that can encode to bit streams.
*/

import Foundation
import CoreGraphics

public protocol BitStreamEncodable {
    func encode(to bitStream: inout WritableBitStream) -> Bool
}

public protocol BitStreamDecodable {
    init?(from bitStream: inout ReadableBitStream)
}

/// - Tag: BitStreamCodable
public typealias BitStreamCodable = BitStreamDecodable & BitStreamEncodable

extension BitStreamEncodable where Self: Encodable {
    func encode(to bitStream: inout WritableBitStream) throws {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        let data = try encoder.encode(self)
        bitStream.append(data)
    }
}

extension BitStreamDecodable where Self: Decodable {
    init(from bitStream: inout ReadableBitStream) throws {
        let data = try bitStream.readData()
        let decoder = PropertyListDecoder()
        self = try decoder.decode(Self.self, from: data)
    }
}

public func bitStreamCodableByteSize(_ object: BitStreamCodable) -> Int {
    var writeStream = WritableBitStream()
    _ = object.encode(to: &writeStream)
    return writeStream.packData().count
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
    
    public init?(from bitStream: inout ReadableBitStream) {
        do {
            self = try bitStream.readUInt32()
        } catch let error {
            print("Error decoding UInt32")
            print(error)
            return nil
        }
    }
    
    func encode(to bitStream: inout WritableBitStream, numberOfBits: Int) -> Bool {
        bitStream.appendUInt32(self, numberOfBits: numberOfBits)
        return true
    }
    
    public func encode(to bitStream: inout WritableBitStream) -> Bool {
        bitStream.appendUInt32(self)
        return true
    }
}

extension Float: BitStreamCodable {
    public init?(from bitStream: inout ReadableBitStream) {
        do {
            self = try bitStream.readFloat()
        } catch let error {
            print("Error decoding Float")
            print(error)
            return nil
        }
    }
    
    public func encode(to bitStream: inout WritableBitStream) -> Bool {
        bitStream.appendFloat(self)
        return true
    }
}


#if canImport(CoreGraphics)
extension CGFloat: BitStreamCodable {
    public init?(from bitStream: inout ReadableBitStream) {
        do {
            self = try bitStream.readCGFloat()
        } catch let error {
            print("Error decoding CGFloat.")
            print(error)
            return nil
        }
    }
    
    public func encode(to bitStream: inout WritableBitStream) -> Bool {
        bitStream.appendCGFloat(self)
        return true
    }
}
#endif
