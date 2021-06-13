//
//  Vector Math Extensions.swift
//  
//
//  Created by Sebastian Toivonen on 16.3.2020.
//
//  Copyright © 2021 Sebastian Toivonen. All rights reserved.

import Foundation
import GLMSwift

/// Returns the parameter on the given line. To determine the closest point: p = p1 + t * (p2 - p1), where t is the result of this function
@_specialize(where T == Float)
@_specialize(where T == Double)
public func closestPointOnLine<T: FloatingPoint>(start p1: Vector2<T>, end p2: Vector2<T>, point: Vector2<T>) -> T {
    let s = p2 - p1
    let q = Vector2<T>(s.y, -s.x).normalized
    return (q.cross(p1 - point)) / s.cross(q)
}

/// Returns the parameters for the intersection points. To determine the points: p1 = start + t1 * (end - start) and p2 = start + t2 * (end - start) where t1 and t2 are the values of the returned tuple
@_specialize(where T == Float)
@_specialize(where T == Double)
public func intersectionPointLineCircle<T: FloatingPoint>(start a: Vector2<T>, end b: Vector2<T>, circlePoint c: Vector2<T>, radius r: T) -> (t1: T?, t2: T?) {
    let s = b - a
    let q = a - c
    let alpha = -2 * s.dot(q)
    let ss = s.lengthSquared
    let alphaSquared = alpha * alpha
    let discriminant = alphaSquared - 4 * ss * (q.lengthSquared - r * r)
    if discriminant < 0 {
        return (t1: nil, t2: nil)
    } else if discriminant == 0 {
        return (t1: alpha / (2 * ss), t2: alpha / (2 * ss))
    } else {
        let sqrtDisc = sqrt(discriminant)
        return (t1: (alpha + sqrtDisc) / (2 * ss), t2: (alpha - sqrtDisc) / (2 * ss))
    }
}

@_specialize(where T == Float)
@_specialize(where T == Double)
public func lineIntersectsCircle<T: FloatingPoint>(start a: Vector2<T>, end b: Vector2<T>, circlePoint c: Vector2<T>, radius r: T) -> Bool {
    let parameters = intersectionPointLineCircle(start: a, end: b, circlePoint: c, radius: r)
    if parameters.t1 == nil || parameters.t2 == nil {
        return false
    }
    return (parameters.t1! >= 0 && parameters.t1! <= 1) || (parameters.t2! >= 0 && parameters.t2! <= 1)
}

@_specialize(where T == Float)
@_specialize(where T == Double)
public func lerp<T: BinaryFloatingPoint>(_ start: Vector2<T>, end: Vector2<T>, t: T) -> Vector2<T> {
    return Vector2<T>(lerp(start.x, end: end.x, t: t), lerp(start.y, end: end.y, t: t))
}

@_specialize(where T == Float)
@_specialize(where T == Double)
public func lerp<T: BinaryFloatingPoint>(_ start: Vector3<T>, end: Vector3<T>, t: T) -> Vector3<T> {
    return Vector3(lerp(start.x, end: end.x, t: t), lerp(start.y, end: end.y, t: t), lerp(start.z, end: end.y, t: t))
}
