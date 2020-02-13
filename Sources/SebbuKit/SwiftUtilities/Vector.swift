//
//  Vector.swift
//  
//
//  Created by Sebastian Toivonen on 13.2.2020.
//  Copyright © 2020 Sebastian Toivonen. All rights reserved.
//

import Foundation
import VectorMath

var vec1 = Vector2(x: 1.2, y: 1.2)
var vec2 = Vector2(x: 1.3, y: 1.3)
var vex3 = vec2 - vec1

public struct Vector2<T: FloatingPoint> {
    public var x: T
    public var y: T
    
    public init(x: T, y: T) {
        self.x = x
        self.y = y
    }
    
    public static func +(lhs: Vector2, rhs: Vector2) -> Vector2 {
        return Vector2(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    public static func -(lhs: Vector2, rhs: Vector2) -> Vector2 {
        return Vector2(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    public static func *(lhs: Vector2, rhs: T) -> Vector2 {
        return Vector2(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    
    public static func *(lhs: T, rhs: Vector2) -> Vector2 {
        return rhs * lhs
    }
    
    public static func += (left: inout Vector2, right: Vector2) {
        left = left + right
    }
    
    public static func -= (left: inout Vector2, right: Vector2) {
        left = left - right
    }
}
