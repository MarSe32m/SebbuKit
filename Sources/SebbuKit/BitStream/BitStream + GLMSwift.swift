//
//  BitStream + GLMSwift.swift
//  
//
//  Created by Sebastian Toivonen on 4.7.2021.
//

import GLMSwift

public extension WritableBitStream {
    @inlinable
    mutating func append(_ value: Vector2<Float>) {
        append(value.x)
        append(value.y)
    }
    
    @inlinable
    mutating func append(_ value: Vector2<Double>) {
        append(value.x)
        append(value.y)
    }
    
    @inlinable
    mutating func append(_ value: Vector3<Float>) {
        append(value.x)
        append(value.y)
        append(value.z)
    }
    
    @inlinable
    mutating func append(_ value: Vector3<Double>) {
        append(value.x)
        append(value.y)
        append(value.z)
    }
    
    @inlinable
    mutating func append(_ value: Vector4<Float>) {
        append(value.x)
        append(value.y)
        append(value.z)
        append(value.w)
    }
    
    @inlinable
    mutating func append(_ value: Vector4<Double>) {
        append(value.x)
        append(value.y)
        append(value.z)
        append(value.w)
    }
}

public extension ReadableBitStream {
    @inlinable
    mutating func read() throws -> Vector2<Float> {
        Vector2<Float>(try read(), try read())
    }
    
    @inlinable
    mutating func read() throws -> Vector2<Double> {
        Vector2<Double>(try read(), try read())
    }
    
    @inlinable
    mutating func read() throws -> Vector3<Float> {
        Vector3<Float>(try read(), try read(), try read())
    }
    
    @inlinable
    mutating func read() throws -> Vector3<Double> {
        Vector3<Double>(try read(), try read(), try read())
    }
    
    @inlinable
    mutating func read() throws -> Vector4<Float> {
        Vector4<Float>(try read(), try read(), try read(), try read())
    }
    
    @inlinable
    mutating func read() throws -> Vector4<Double> {
        Vector4<Double>(try read(), try read(), try read(), try read())
    }
}
