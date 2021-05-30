//
//  BitStreamCodable.swift
//
//  Created by Sebastian Toivonen on 24.12.2019.
//
//  Copyright © 2021 Sebastian Toivonen. All rights reserved.
import Foundation

public protocol BitStreamEncodable {
    func encode(to bitStream: inout WritableBitStream)
}

public protocol BitStreamDecodable {
    init(from bitStream: inout ReadableBitStream) throws
}

/// - Tag: BitStreamCodable
public typealias BitStreamCodable = BitStreamEncodable & BitStreamDecodable

public extension BitStreamEncodable where Self: Encodable {
    func encode(to bitStream: inout WritableBitStream) {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        if let data = try? encoder.encode(self) {
            bitStream.append(data)
        } else {
            print("Failed to encode Encodable data...", #file, #line)
        } //TODO: Maybe just forget about this extension all together
    }
}

public extension BitStreamDecodable where Self: Decodable {
    init(from bitStream: inout ReadableBitStream) throws {
        let data: Data = try bitStream.read()
        let decoder = PropertyListDecoder()
        self = try decoder.decode(Self.self, from: data)
    }
}

extension String {
    public init(from bitStream: inout ReadableBitStream) throws {
        if let result = try bitStream.read() as String? {
            self = result
        }
        throw BitStreamError.encodingError
    }

    public func encode(to bitStream: inout WritableBitStream) -> Bool {
        bitStream.append(self)
    }
}

extension Array: BitStreamCodable where Element == UInt8 {
    public init(from bitStream: inout ReadableBitStream) throws {
        self = try bitStream.read()
    }
    
    @inlinable
    public func encode(to bitStream: inout WritableBitStream) {
        bitStream.append(self)
    }
}

extension Array where Element: BitStreamCodable {
    public init(from bitStream: inout ReadableBitStream) throws {
        let count = try bitStream.read() as Int
        var result = [Element]()
        for _ in 0..<count {
            result.append(try Element(from: &bitStream))
        }
        self = result
    }
    
    @inlinable
    public func encode(to bitStream: inout WritableBitStream) {
        bitStream.append(count)
        for element in self {
            element.encode(to: &bitStream)
        }
    }
}

extension UInt32: BitStreamCodable {
    init?(from bitStream: inout ReadableBitStream, numberOfBits: Int) throws {
        self = try bitStream.read(numberOfBits: numberOfBits)
    }
    
    @inline(__always)
    public init(from bitStream: inout ReadableBitStream) throws {
        self = try bitStream.read()
    }
    
    @inline(__always)
    func encode(to bitStream: inout WritableBitStream, numberOfBits: Int) {
        bitStream.append(self, numberOfBits: numberOfBits)
    }
    
    @inline(__always)
    public func encode(to bitStream: inout WritableBitStream) {
        bitStream.append(self)
    }
}

extension Float: BitStreamCodable {
    public init(from bitStream: inout ReadableBitStream) throws {
        self = try bitStream.read()
    }
    
    @inline(__always)
    public func encode(to bitStream: inout WritableBitStream) {
        bitStream.append(self)
    }
}

extension Double: BitStreamCodable {
    public init(from bitStream: inout ReadableBitStream) throws {
        self = try bitStream.read()
    }
    
    @inline(__always)
    public func encode(to bitStream: inout WritableBitStream) {
        bitStream.append(self)
    }
}

#if canImport(CoreGraphics)
import CoreGraphics
extension CGFloat: BitStreamCodable {
    public init(from bitStream: inout ReadableBitStream) throws {
        self = try bitStream.read()
    }
    
    @inline(__always)
    public func encode(to bitStream: inout WritableBitStream) {
        bitStream.append(self)
    }
}
#endif
