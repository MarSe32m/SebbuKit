//
//  FloatingPointExtensions.swift
//  
//
//  Created by Sebastian Toivonen on 31.1.2020.
//  Copyright © 2020 Sebastian Toivonen. All rights reserved.
//
import Foundation

public func invSqrt(x: Double) -> Double {
    let halfx = 0.5 * x
    var i = x.bitPattern
    i = 0x5f3759df - (i >> 1)
    var y = Double(bitPattern: i)
    y = y * (1.5 - (halfx * y * y))
    return y
}

public func invSqrt(x: Float) -> Float {
    let halfx = 0.5 * x
    var i = x.bitPattern
    i = 0x5f3759df - (i >> 1)
    var y = Float(bitPattern: i)
    y = y * (1.5 - (halfx * y * y))
    return y
}

public func solveQuadratic(a: Float, b: Float, c: Float) -> (found: Bool, x1: Float, x2: Float) {
    if a == 0 {
        if b == 0 {
            return (c == 0, 0, 0)
        } else {
            return (true, -c/b,-c/b)
        }
    }
    if b == 0 {
        return (-c/a >= 0, sqrt(-c/a), -sqrt(-c/a))
    } else if c == 0 {
        return (true, 0, -b / a)
    }
    
    let discriminant = b*b - 4*a*c
    if discriminant >= 0 {
        return (true, (-b + sqrt(discriminant))/(2 * a), (-b - sqrt(discriminant))/(2 * a))
    }
    return (false, 0, 0)
}

public func smoothMin(a: Float, b: Float, k: Float) -> Float {
    if k == 0 {
        return min(a, b)
    }
    let h = max(k - abs(a - b), 0) / k
    return min(a, b) - h*h*h*h*1/6.0
}

public func lerp(_ start: Float, end: Float, t: Float) -> Float {
    return start + (end - start) * t
}

public func lerp(_ start: Double, end: Double, t: Double) -> Double {
    return start + (end - start) * t
}

public func ln(_ value: Double) -> Double {
    return log(value) / log(M_E)
}

func exponentialSmoothingFunction(t: Float) -> Float {
    return (t == 1.0) ? t : 1.0 - pow(Float(M_E), -6.0 * t)
}

public postfix func ++(a: inout Int) -> Int {
    a += 1
    return a - 1
}

public prefix func ++(a: inout Int) -> Int {
    a += 1
    return a
}

public postfix func ++(a: inout UInt64) -> UInt64 {
    a += 1
    return a - 1
}

public prefix func ++(a: inout UInt64) -> UInt64 {
    a += 1
    return a
}

public func smoothDamp(current c: Float, target t: Float, currentVelocity: inout Float, smoothTime time: Float, maxSpeed: Float = Float.infinity, deltaTime: Float) -> Float {
    let smoothTime = max(0.0001, time)
    let num  = 2 / smoothTime
    let num2 = num * deltaTime
    let num3 = 1 / (1 + num2 + 0.48 * num2 * num2 + 0.235 * num2 * num2 * num2)
    var num4 = c - t
    let num5 = t
    let num6 = maxSpeed * smoothTime
    num4 = min(max(num4, -num6), num6)
    let target = c - num4
    let num7 = (currentVelocity + num * num4) * deltaTime
    currentVelocity = (currentVelocity - num * num7) * num3
    var num8 = target + (num4 + num7) * num3
    if (num5 - c > 0) == (num8 > num5) {
        num8 = num5
        currentVelocity = (num8 - num5) / deltaTime
    }
    return num8
}

public func smoothDamp(current c: Double, target t: Double, currentVelocity: inout Double, smoothTime time: Double, maxSpeed: Double = Double.infinity, deltaTime: Double) -> Double {
    let smoothTime = max(0.0001, time)
    let num  = 2 / smoothTime
    let num2 = num * deltaTime
    let num3 = 1 / (1 + num2 + 0.48 * num2 * num2 + 0.235 * num2 * num2 * num2)
    var num4 = c - t
    let num5 = t
    let num6 = maxSpeed * smoothTime
    num4 = min(max(num4, -num6), num6)
    let target = c - num4
    let num7 = (currentVelocity + num * num4) * deltaTime
    currentVelocity = (currentVelocity - num * num7) * num3
    var num8 = target + (num4 + num7) * num3
    if (num5 - c > 0) == (num8 > num5) {
        num8 = num5
        currentVelocity = (num8 - num5) / deltaTime
    }
    return num8
}

public func hermiteSpline(startPos: (x: Float, y: Float), startVelocity: (dx: Float, dy: Float), endPos: (x: Float, y: Float), endVelocity: (dx: Float, dy: Float), t: Float) -> (x: Float, y: Float) {
    var result: (x: Float, y: Float) = (0.0, 0.0)
    let t2 = t * t
    let t3 = t2 * t
    
    let d1 = (2 * t3 - 3 * t2 + 1)
    result.x += d1 * startPos.x
    result.y += d1 * startPos.y
    
    let d2 = (t3 - 2 * t2 + t)
    result.x += d2 * startVelocity.dx
    result.y += d2 * startVelocity.dy
    
    let d3 = (-2 * t3 + 3 * t2)
    result.x += d3 * endPos.x
    result.y += d3 * endPos.y
    
    let d4 = (t3 - t2)
    result.x += d4 * endVelocity.dx
    result.y += d4 * endVelocity.dy
    return result
}


#if canImport(CoreGraphics)
import CoreGraphics
public func solveQuadratic(a: CGFloat, b: CGFloat, c: CGFloat) -> (found: Bool, x1: CGFloat, x2: CGFloat) {
    let result = solveQuadratic(a: Float(a), b: Float(b), c: Float(c))
    return (result.found, CGFloat(result.x1), CGFloat(result.x2))
}

public func invSqrt(x: CGFloat) -> CGFloat {
    let halfx = 0.5 * x
    var i = x.bitPattern
    i = 0x5f3759df - (i >> 1)
    var y = CGFloat(bitPattern: i)
    y = y * (1.5 - (halfx * y * y))
    return y
}

public func smoothMin(a: CGFloat, b: CGFloat, k: CGFloat) -> CGFloat {
    if k == 0 {
        return min(a, b)
    }
    let h = max(k - abs(a - b), 0) / k
    return min(a, b) - h*h*h*h*1/6.0
}

public func ln(_ value: CGFloat) -> CGFloat {
    return log(value) / log(CGFloat(M_E))
}

public func sign(value: CGFloat) -> Int {
    return value >= 0 ? 1 : -1
}

public func smoothDamp(current c: CGFloat, target t: CGFloat, currentVelocity: inout CGFloat, smoothTime time: CGFloat, maxSpeed: CGFloat = CGFloat.infinity, deltaTime: CGFloat) -> CGFloat {
    let smoothTime = max(0.0001, time)
    let num  = 2 / smoothTime
    let num2 = num * deltaTime
    let num3 = 1 / (1 + num2 + 0.48 * num2 * num2 + 0.235 * num2 * num2 * num2)
    var num4 = c - t
    let num5 = t
    let num6 = maxSpeed * smoothTime
    num4 = min(max(num4, -num6), num6)
    let target = c - num4
    let num7 = (currentVelocity + num * num4) * deltaTime
    currentVelocity = (currentVelocity - num * num7) * num3
    var num8 = target + (num4 + num7) * num3
    if (num5 - c > 0) == (num8 > num5) {
        num8 = num5
        currentVelocity = (num8 - num5) / deltaTime
    }
    return num8
}

public func hermiteSpline(startPos: CGPoint, startVelocity: CGVector, endPos: CGPoint, endVelocity: CGVector, t: CGFloat) -> CGPoint {
    var result = CGPoint.zero
    let t2 = t * t
    let t3 = t2 * t
    let d1 = (2 * t3 - 3 * t2 + 1)
    let d2 = (t3 - 2 * t2 + t)
    let d3 = (-2 * t3 + 3 * t2)
    let d4 = (t3 - t2)
    
    result += d1 * startPos
    result += d2 * startVelocity
    result += d3 * endPos
    result += d4 * endVelocity
    return result
}

func collisionPoint(targetStartPosition: CGPoint, targetVelocity: CGVector, bulletStartPosition: CGPoint, bulletSpeed: CGFloat) -> CGPoint? {
    let a = targetVelocity.lengthSquared() - bulletSpeed * bulletSpeed
    let b = 2 * (targetVelocity.dx * (targetStartPosition.x - bulletStartPosition.x) + targetVelocity.dy * (targetStartPosition.y - bulletStartPosition.y))
    let c = (targetStartPosition - bulletStartPosition).lengthSquared()
    let d = b * b - 4 * a * c
    
    if d < 0 {
        return nil
    }
    
    let t1 = (-b + d) / (2 * a)
    let t2 = (-b - d) / (2 * a)
    
    let t = max(0, min(t1, t2))
    
    if t == 0 {
        return nil
    }
    
    let targetPos = targetStartPosition + targetVelocity * t
    return targetPos
}

public func smoothDamp(currentVector: CGVector, targetVector: CGVector, currentVelocity: inout CGVector, smoothTime time: CGFloat, deltaTime: CGFloat) -> CGVector {
    let newDX = smoothDamp(current: currentVector.dx, target: targetVector.dx, currentVelocity: &currentVelocity.dx, smoothTime: time, deltaTime: deltaTime)
    let newDY = smoothDamp(current: currentVector.dy, target: targetVector.dy, currentVelocity: &currentVelocity.dy, smoothTime: time, deltaTime: deltaTime)
    return CGVector(dx: newDX, dy: newDY)
}

public func smoothDamp(currentPosition: CGPoint, targetPosition: CGPoint, currentVelocity: inout CGVector, smoothTime time: CGFloat, deltaTime: CGFloat) -> CGPoint {
    let newX = smoothDamp(current: currentPosition.x, target: targetPosition.x, currentVelocity: &currentVelocity.dx, smoothTime: time, deltaTime: deltaTime)
    let newY = smoothDamp(current: currentPosition.y, target: targetPosition.y, currentVelocity: &currentVelocity.dy, smoothTime: time, deltaTime: deltaTime)
    return CGPoint(x: newX, y: newY)
}

public extension CGFloat {
    func roundTo(decimals: Int) -> CGFloat {
        var divider = 10
        var float: CGFloat = self
        if decimals == 0 {
            float = CGFloat(Int(float))
            return float
        } else if decimals == 1 {
            let intValue = Int(float * CGFloat(divider))
            return CGFloat(intValue) / CGFloat(divider)
        }
        for _ in 1..<decimals {
            divider *= 10
        }
        let intValue = Int(float * CGFloat(divider))
        return CGFloat(intValue) / CGFloat(divider)
    }
}

#endif
