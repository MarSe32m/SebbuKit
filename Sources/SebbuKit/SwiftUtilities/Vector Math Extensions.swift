//
//  Vector Math Extensions.swift
//  
//
//  Created by Sebastian Toivonen on 16.3.2020.
//

import Foundation
import VectorMath

//MARK: Vector2 arithmetics
public extension Vector2 {
    static func += (lhs: inout Vector2, rhs: Vector2) {
        lhs = lhs + rhs
    }

    static func -= (lhs: inout Vector2, rhs: Vector2) {
        lhs = lhs - rhs
    }

    static func *= (lhs: inout Vector2, rhs: Scalar) {
        lhs = lhs * rhs
    }
}


//MARK: Vector3 arithmetics
public extension Vector3 {
    static func += (lhs: inout Vector3, rhs: Vector3) {
        lhs = lhs + rhs
    }

    static func -= (lhs: inout Vector3, rhs: Vector3) {
        lhs = lhs - rhs
    }

    static func *= (lhs: inout Vector3, rhs: Scalar) {
        lhs = lhs * rhs
    }
}

//MARK: Vector4 arithmetics
public extension Vector4 {
    static func += (lhs: inout Vector4, rhs: Vector4) {
        lhs = lhs + rhs
    }

    static func -= (lhs: inout Vector4, rhs: Vector4) {
        lhs = lhs - rhs
    }

    static func *= (lhs: inout Vector4, rhs: Scalar) {
        lhs = lhs * rhs
    }
}

//MARK: Matrix3 arithmetics
public extension Matrix3 {
    static func + (lhs: Matrix3, rhs: Matrix3) -> Matrix3 {
        Matrix3(lhs.m11 + rhs.m11, lhs.m12 + rhs.m12, lhs.m13 + rhs.m13,
                lhs.m21 + rhs.m21, lhs.m22 + rhs.m22, lhs.m23 + rhs.m23,
                lhs.m31 + rhs.m31, lhs.m32 + rhs.m32, lhs.m33 + rhs.m33)
    }

    static func - (lhs: Matrix3, rhs: Matrix3) -> Matrix3 {
        Matrix3(lhs.m11 - rhs.m11, lhs.m12 - rhs.m12, lhs.m13 - rhs.m13,
                lhs.m21 - rhs.m21, lhs.m22 - rhs.m22, lhs.m23 - rhs.m23,
                lhs.m31 - rhs.m31, lhs.m32 - rhs.m32, lhs.m33 - rhs.m33)
    }
    
    static func += (lhs: inout Matrix3, rhs: Matrix3) {
        lhs = lhs + rhs
    }

    static func -= (lhs: inout Matrix3, rhs: Matrix3) {
        lhs = lhs - rhs
    }

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
