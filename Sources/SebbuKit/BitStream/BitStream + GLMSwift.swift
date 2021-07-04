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
