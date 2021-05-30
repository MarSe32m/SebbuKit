//
//  CGExtensions.swift
//
//  Created by Sebastian on 25.6.2016.
//  Copyright © 2021 Sebastian Toivonen. All rights reserved.
//

#if canImport(CoreGraphics)
import Foundation
import CoreGraphics

public extension CGFloat {
    
    @inline(__always)
    mutating func toRadians() -> CGFloat {
        self *= (.pi / 180)
        return self
    }
    
    @inline(__always)
    mutating func toDegrees() -> CGFloat {
        self *= (180 / .pi)
        return self
    }
}

public extension CGPoint {
    
    @inline(__always)
    mutating func offset(_ dx: CGFloat, dy: CGFloat) -> CGPoint {
        x += dx
        y += dy
        return self
    }
    
    @inline(__always)
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    @inline(__always)
    func lengthSquared() -> CGFloat {
        return x*x + y*y
    }
    
    @inline(__always)
    func normalized() -> CGPoint {
        let len = length()
        return len > 0 ? self / len : CGPoint.zero
    }
    
    @inline(__always)
    mutating func normalize() {
        self = normalized()
    }
    
    @inline(__always)
    func distanceTo(_ point: CGPoint) -> CGFloat {
        return (self - point).length()
    }
    
    @inline(__always)
    func squareDistanceTo(_ point: CGPoint) -> CGFloat {
        return (self - point).lengthSquared()
    }
    
    @inline(__always)
    var angle: CGFloat {
        return atan2(y, x)
    }
    
    @inline(__always)
    func rotated(by: CGFloat) -> CGPoint {
        return CGPoint(x: x * cos(by) - y * sin(by),
                        y: x * sin(by) + y * cos(by))
    }
    
    @inline(__always)
    static func random<T>(xRange: Range<CGFloat>, yRange: Range<CGFloat>, using generator: inout T) -> CGPoint where T : RandomNumberGenerator {
        CGPoint(x: .random(in: xRange, using: &generator), y: .random(in: yRange, using: &generator))
    }
    
    @inline(__always)
    static func random<T>(xRange: ClosedRange<CGFloat>, yRange: ClosedRange<CGFloat>, using generator: inout T) -> CGPoint where T : RandomNumberGenerator {
        CGPoint(x: .random(in: xRange, using: &generator), y: .random(in: yRange, using: &generator))
    }
    
    @inline(__always)
    static func random(xRange: Range<CGFloat>, yRange: Range<CGFloat>) -> CGPoint {
        return CGPoint(x: CGFloat.random(in: xRange), y: CGFloat.random(in: yRange))
    }
    
    @inline(__always)
    static func random(xRange: ClosedRange<CGFloat>, yRange: ClosedRange<CGFloat>) -> CGPoint {
        return CGPoint(x: CGFloat.random(in: xRange), y: CGFloat.random(in: yRange))
    }
}

public extension CGVector {
    
    init(point: CGPoint) {
        self.init()
        self.dx = point.x
        self.dy = point.y
    }
    
    @inline(__always)
    func squaredLength() -> CGFloat {
        return dx*dx + dy*dy
    }
    
    @inline(__always)
    func unitVector() -> CGVector {
        let len = length()
        if len == 0 {
            return CGVector.zero
        }
        return self / len
    }
    
    @inline(__always)
    func orthogonalProjection(onto vector: CGVector) -> CGVector {
        let dotProduct = self * vector
        return dotProduct / (vector.lengthSquared()) * vector
    }
    
    @inline(__always)
    func length() -> CGFloat {
        sqrt(dx * dx + dy * dy)
    }
    
    @inline(__always)
    func lengthSquared() -> CGFloat {
        dx * dx + dy * dy
    }
    
    @inline(__always)
    func normalized() -> CGVector {
        self / length()
    }
    
    @inline(__always)
    var angle: CGFloat {
        atan2(dy, dx)
    }

    /// Dot product
    @inline(__always)
    static func * (left: CGVector, right: CGVector) -> CGFloat {
        left.dx*right.dx + left.dy*right.dy
    }
    
    @inline(__always)
    func dot(_ other: CGVector) -> CGFloat {
        self * other
    }
    
    @inline(__always)
    func rotated(by: CGFloat) -> CGVector {
        return CGVector(dx: dx * cos(by) - dy * sin(by),
                        dy: dx * sin(by) + dy * cos(by))
    }
    
    @inline(__always)
    func angle(with v: CGVector) -> CGFloat {
        if self == v {
            return 0
        }
        
        let t1 = normalized()
        let t2 = v.normalized()
        let cross = t1.cross(t2)
        let dot = max(-1, min(1, t1.dot(t2)))

        return atan2(cross, dot)
    }
    
    @inline(__always)
    func cross(_ other: CGVector) -> CGFloat {
        dx * other.dy - dy * other.dx
    }
}

public extension CGSize {
    func aspectFill(_ target: CGSize) -> CGSize {
        let baseAspect = self.width / self.height
        let targetAspect = target.width / target.height
        if baseAspect > targetAspect {
            return CGSize(width: (target.height * width) / height, height: target.height)
        } else {
            return CGSize(width: target.width, height: (target.width * height) / width)
        }
    }
}

@inline(__always)
public func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

@inline(__always)
public func += ( left: inout CGPoint, right: CGPoint) {
    left = left + right
}

@inline(__always)
public func + (left: CGPoint, right: CGVector) -> CGPoint {
    return CGPoint(x: left.x + right.dx, y: left.y + right.dy)
}

@inline(__always)
public func += ( left: inout CGPoint, right: CGVector) {
    left = left + right
}

@inline(__always)
public func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

@inline(__always)
public func -= ( left: inout CGPoint, right: CGPoint) {
    left = left - right
}

@inline(__always)
public func - (left: CGPoint, right: CGVector) -> CGPoint {
    return CGPoint(x: left.x - right.dx, y: left.y - right.dy)
}

@inline(__always)
public func -= ( left: inout CGPoint, right: CGVector) {
    left = left - right
}

@inline(__always)
public func * (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x * right.x, y: left.y * right.y)
}

@inline(__always)
public func *= ( left: inout CGPoint, right: CGPoint) {
    left = left * right
}

@inline(__always)
public func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

@inline(__always)
public func * (point: CGPoint, scalar: Int) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

@inline(__always)
public func * (scalar: Int, point: CGPoint) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

@inline(__always)
public func * (cgfloat: CGFloat, integer: Int) -> CGFloat {
    return CGFloat(integer) * cgfloat
}

@inline(__always)
public func * (integer: Int, cgfloat: CGFloat) -> CGFloat {
    return CGFloat(integer) * cgfloat
}

@inline(__always)
public func * (size: CGSize, scalar: CGFloat) -> CGSize {
    return CGSize(width: size.width * scalar, height: size.height * scalar)
}

@inline(__always)
public func *= (size: inout CGSize, scalar: CGFloat) {
    size = CGSize(width: size.width * scalar, height: size.height * scalar)
}

@inline(__always)
public func * (vector: CGVector, scalar: CGFloat) -> CGVector {
    return CGVector(dx: vector.dx * scalar, dy: vector.dy * scalar)
}

@inline(__always)
public func *= ( point: inout CGPoint, scalar: CGFloat) {
    point = point * scalar
}

@inline(__always)
public func * (left: CGPoint, right: CGVector) -> CGPoint {
    return CGPoint(x: left.x * right.dx, y: left.y * right.dy)
}

@inline(__always)
public func *= ( left: inout CGPoint, right: CGVector) {
    left = left * right
}

@inline(__always)
public func / (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x / right.x, y: left.y / right.y)
}

@inline(__always)
public func /= ( left: inout CGPoint, right: CGPoint) {
    left = left / right
}

@inline(__always)
public func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

@inline(__always)
public func /= ( point: inout CGPoint, scalar: CGFloat) {
    point = point / scalar
}

@inline(__always)
public func / (left: CGPoint, right: CGVector) -> CGPoint {
    return CGPoint(x: left.x / right.dx, y: left.y / right.dy)
}

@inline(__always)
public func / (left: CGVector, right: CGFloat) -> CGVector {
    return CGVector(dx: left.dx / right, dy: left.dy / right)
}

@inline(__always)
public func /= ( left: inout CGPoint, right: CGVector) {
    left = left / right
}

@inline(__always)
public func lerp(_ start: CGPoint, end: CGPoint, t: CGFloat) -> CGPoint {
    return start + (end - start) * t
}

@inline(__always)
public func lerp(_ start: CGVector, end: CGVector, t: CGFloat) -> CGVector {
    return start + (end - start) * t
}

@inline(__always)
public func lerp(_ start: CGFloat, end: CGFloat, t: CGFloat) -> CGFloat {
    return start + (end - start) * t
}

@inline(__always)
public func lerp(_ start: Float, end: Float, t: Float) -> Int {
    return Int(start + (end - start) * t)
}

@inlinable
public func lerpRot(_ start: CGFloat, end: CGFloat, t: CGFloat) -> CGFloat {
    let max = Double.pi * 2
    let da = Double(end - start).truncatingRemainder(dividingBy: max)
    let shortAngleDist = CGFloat((2 * da).truncatingRemainder(dividingBy: max) - da)
    return start + shortAngleDist * t
}

@inlinable
public func lerpRot(_ startAngle: CGFloat, endAngle: CGFloat, t: CGFloat) -> CGFloat {
    let start = Int(radiansToDegrees(radians: startAngle))
    let end = Int(radiansToDegrees(radians: endAngle))
    let shortestAngleInDegrees = CGFloat(((((end - start) % 360) + 540) % 360) - 180)
    let shortestAngle = degreesToRadians(degrees: shortestAngleInDegrees)
    return shortestAngle * t
}

@inline(__always)
public func clamp(current: inout CGFloat, min: CGFloat, max: CGFloat) {
    current = current < min ? min : (current > max) ? max : current
}

@inline(__always)
public func clamp(current: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
    return ((current < min) ? min : (current > max ? max : current))
}

@inlinable
public func clamp(current: CGPoint, min: CGPoint, max: CGPoint) -> CGPoint {
    let newX: CGFloat = clamp(current: current.x, min: min.x, max: max.x)
    let newY: CGFloat = clamp(current: current.y, min: min.y, max: max.y)
    return CGPoint(x: newX, y: newY)
}

@inlinable
public func clamp(current: inout CGPoint, min: CGPoint, max: CGPoint) {
    let newX: CGFloat = clamp(current: current.x, min: min.x, max: max.x)
    let newY: CGFloat = clamp(current: current.y, min: min.y, max: max.y)
    current = CGPoint(x: newX, y: newY)
}

@inlinable
public func clamp(current: CGVector, min: CGVector, max: CGVector) -> CGVector {
    let newX: CGFloat = clamp(current: current.dx, min: min.dx, max: max.dx)
    let newY: CGFloat = clamp(current: current.dy, min: min.dy, max: max.dy)
    return CGVector(dx: newX, dy: newY)
}

@inlinable
public func clamp(current: inout CGVector, min: CGVector, max: CGVector) {
    let newX: CGFloat = clamp(current: current.dx, min: min.dx, max: max.dx)
    let newY: CGFloat = clamp(current: current.dy, min: min.dy, max: max.dy)
    current = CGVector(dx: newX, dy: newY)
}

@inline(__always)
public func degreesToRadians(degrees: CGFloat) -> CGFloat {
    return degrees * (CGFloat.pi / 180)
}

@inline(__always)
public func radiansToDegrees(radians: CGFloat) -> CGFloat {
    return radians * (180 / CGFloat.pi)
}

@inline(__always)
public func crossProductScalar(vector1: CGVector, vector2: CGVector) -> CGFloat{
    return vector1.dx*vector2.dy - vector1.dy*vector2.dx
}

@inline(__always)
public func + (left: CGVector, right: CGVector) -> CGVector {
    return CGVector(dx: left.dx + right.dx, dy: left.dy + right.dy)
}

@inline(__always)
public func += (left: inout CGVector, right: CGVector) {
    left = left + right
}

@inline(__always)
public func - (left: CGVector, right: CGVector) -> CGVector {
    return CGVector(dx: left.dx - right.dx, dy: left.dy - right.dy)
}

@inline(__always)
public func -= (left: inout CGVector, right: CGVector) {
    left = left - right
}

@inline(__always)
public func *= (lhs: inout CGVector, right: CGFloat) {
    lhs = lhs * right
}

@inline(__always)
public func * (left: CGFloat, right: CGPoint) -> CGPoint {
    return CGPoint(x: left * right.x, y: left * right.y)
}

@inline(__always)
public func * (right: CGFloat, left: CGVector) -> CGVector {
    return CGVector(dx: left.dx * right, dy: left.dy * right)
}

@inline(__always)
public func /= (left: inout CGVector, right: CGFloat) {
    left = left / right
}

extension CGPoint: BitStreamCodable {
    
    @inlinable
    public init(from bitStream: inout ReadableBitStream) throws {
        let x = try bitStream.read() as CGFloat
        let y = try bitStream.read() as CGFloat
        self.init(x: x, y: y)
    }
    
    @inline(__always)
    public func encode(to bitStream: inout WritableBitStream) {
        bitStream.append(x)
        bitStream.append(y)
    }
    
}

extension CGVector: BitStreamCodable {
    @inlinable
    public init(from bitStream: inout ReadableBitStream) throws {
        let dx = try bitStream.read() as CGFloat
        let dy = try bitStream.read() as CGFloat
        self.init(dx: dx, dy: dy)
    }
    
    @inline(__always)
    public func encode(to bitStream: inout WritableBitStream) {
        bitStream.append(dx)
        bitStream.append(dy)
    }
    
}
#endif
