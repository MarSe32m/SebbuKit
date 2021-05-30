//
//  Vector Math Extensions.swift
//  
//
//  Created by Sebastian Toivonen on 16.3.2020.
//
//  Copyright © 2021 Sebastian Toivonen. All rights reserved.
#if !os(Windows) //TODO: Replace these with your own library
import Foundation
import VectorMath

//MARK: Vector2 arithmetics
public extension Vector2 {
    @inline(__always)
    static func += (lhs: inout Vector2, rhs: Vector2) {
        lhs = lhs + rhs
    }

    @inline(__always)
    static func -= (lhs: inout Vector2, rhs: Vector2) {
        lhs = lhs - rhs
    }

    @inline(__always)
    static func *= (lhs: inout Vector2, rhs: Scalar) {
        lhs = lhs * rhs
    }
}

//MARK: Vector3 arithmetics
public extension Vector3 {
    @inline(__always)
    static func += (lhs: inout Vector3, rhs: Vector3) {
        lhs = lhs + rhs
    }

    @inline(__always)
    static func -= (lhs: inout Vector3, rhs: Vector3) {
        lhs = lhs - rhs
    }
    
    @inline(__always)
    static func *= (lhs: inout Vector3, rhs: Scalar) {
        lhs = lhs * rhs
    }
}

//MARK: Vector4 arithmetics
public extension Vector4 {
    @inline(__always)
    static func += (lhs: inout Vector4, rhs: Vector4) {
        lhs = lhs + rhs
    }

    @inline(__always)
    static func -= (lhs: inout Vector4, rhs: Vector4) {
        lhs = lhs - rhs
    }

    @inline(__always)
    static func *= (lhs: inout Vector4, rhs: Scalar) {
        lhs = lhs * rhs
    }
}

//MARK: Matrix3 arithmetics
public extension Matrix3 {
    @inline(__always)
    static func + (lhs: Matrix3, rhs: Matrix3) -> Matrix3 {
        Matrix3(lhs.m11 + rhs.m11, lhs.m12 + rhs.m12, lhs.m13 + rhs.m13,
                lhs.m21 + rhs.m21, lhs.m22 + rhs.m22, lhs.m23 + rhs.m23,
                lhs.m31 + rhs.m31, lhs.m32 + rhs.m32, lhs.m33 + rhs.m33)
    }

    @inline(__always)
    static func - (lhs: Matrix3, rhs: Matrix3) -> Matrix3 {
        Matrix3(lhs.m11 - rhs.m11, lhs.m12 - rhs.m12, lhs.m13 - rhs.m13,
                lhs.m21 - rhs.m21, lhs.m22 - rhs.m22, lhs.m23 - rhs.m23,
                lhs.m31 - rhs.m31, lhs.m32 - rhs.m32, lhs.m33 - rhs.m33)
    }
    
    @inline(__always)
    static func += (lhs: inout Matrix3, rhs: Matrix3) {
        lhs = lhs + rhs
    }

    @inline(__always)
    static func -= (lhs: inout Matrix3, rhs: Matrix3) {
        lhs = lhs - rhs
    }

    @inline(__always)
    static func *= (lhs: inout Matrix3, rhs: Matrix3) {
        lhs = lhs * rhs
    }
}




//MARK: Matrix4 arithmetics
public extension Matrix4 {
    static func + (lhs: Matrix4, rhs: Matrix4) -> Matrix4 {
        Matrix4(lhs.m11 + rhs.m11, lhs.m12 + rhs.m12, lhs.m13 + rhs.m13, lhs.m14 + rhs.m14,
                lhs.m21 + rhs.m21, lhs.m22 + rhs.m22, lhs.m23 + rhs.m23, lhs.m24 + rhs.m24,
                lhs.m31 + rhs.m31, lhs.m32 + rhs.m32, lhs.m33 + rhs.m33, lhs.m34 + rhs.m34,
                lhs.m41 + rhs.m41, lhs.m42 + rhs.m42, lhs.m43 + rhs.m43, lhs.m44 + rhs.m44)
    }

    static func - (lhs: Matrix4, rhs: Matrix4) -> Matrix4 {
        Matrix4(lhs.m11 - rhs.m11, lhs.m12 - rhs.m12, lhs.m13 - rhs.m13, lhs.m14 - rhs.m14,
                lhs.m21 - rhs.m21, lhs.m22 - rhs.m22, lhs.m23 - rhs.m23, lhs.m24 - rhs.m24,
                lhs.m31 - rhs.m31, lhs.m32 - rhs.m32, lhs.m33 - rhs.m33, lhs.m34 - rhs.m34,
                lhs.m41 - rhs.m41, lhs.m42 - rhs.m42, lhs.m43 - rhs.m43, lhs.m44 - rhs.m44)
    }
    
    static func += (lhs: inout Matrix4, rhs: Matrix4) {
        lhs = lhs + rhs
    }

    static func -= (lhs: inout Matrix4, rhs: Matrix4) {
        lhs = lhs - rhs
    }

    static func *= (lhs: inout Matrix4, rhs: Matrix4) {
        lhs = lhs * rhs
    }
}
/// Returns the parameter on the given line. To determine the closest point: p = p1 + t * (p2 - p1), where t is the result of this function
public func closestPointOnLine(start p1: Vector2, end p2: Vector2, point: Vector2) -> Float {
    let s = p2 - p1
    let q = Vector2(s.y, -s.x).normalized()
    return (q.cross(p1 - point)) / s.cross(q)
}

/// Returns the parameters for the intersection points. To determine the points: p1 = start + t1 * (end - start) and p2 = start + t2 * (end - start) where t1 and t2 are the values of the returned tuple
public func intersectionPointLineCircle(start a: Vector2, end b: Vector2, circlePoint c: Vector2, radius r: Float) -> (t1: Float, t2: Float) {
    let s = b - a
    let q = a - c
    let alpha = -2 * s.dot(q)
    let ss = s.lengthSquared
    let discriminant = alpha * alpha - 4 * ss * (q.lengthSquared - r * r)
    if discriminant < 0 {
        return (t1: Float.nan, t2: Float.nan)
    } else if discriminant == 0 {
        return (t1: alpha / (2 * ss), t2: Float.nan)
    } else {
        let sqrtDisc = sqrt(discriminant)
        return (t1: (alpha + sqrtDisc) / (2 * ss), t2: (alpha - sqrtDisc) / (2 * ss))
    }
}

public func lineIntersectsCircle(start a: Vector2, end b: Vector2, circlePoint c: Vector2, radius r: Float) -> Bool {
    let parameters = intersectionPointLineCircle(start: a, end: b, circlePoint: c, radius: r)
    return (parameters.t1 >= 0 && parameters.t1 <= 1) || (parameters.t2 >= 0 && parameters.t2 <= 1)
}

public func lerp(_ start: Vector2, end: Vector2, t: Float) -> Vector2 {
    return Vector2(lerp(start.x, end: end.x, t: t), lerp(start.y, end: end.y, t: t))
}

public func lerp(_ start: Vector3, end: Vector3, t: Float) -> Vector3 {
    return Vector3(lerp(start.x, end: end.x, t: t), lerp(start.y, end: end.y, t: t), lerp(start.z, end: end.y, t: t))
}
#endif
