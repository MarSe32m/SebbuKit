//
//  Vector Math Extensions.swift
//  
//
//  Created by Sebastian Toivonen on 16.3.2020.
//

import Foundation
import VectorMath

//MARK: Vector2 arithmetics
public func += (lhs: inout Vector2, rhs: Vector2) {
    lhs = lhs + rhs
}

public func -= (lhs: inout Vector2, rhs: Vector2) {
    lhs = lhs - rhs
}

public func *= (lhs: inout Vector2, rhs: Scalar) {
    lhs = lhs * rhs
}

//MARK: Vector3 arithmetics
public func += (lhs: inout Vector3, rhs: Vector3) {
    lhs = lhs + rhs
}

public func -= (lhs: inout Vector3, rhs: Vector3) {
    lhs = lhs - rhs
}

public func *= (lhs: inout Vector3, rhs: Scalar) {
    lhs = lhs * rhs
}

//MARK: Vector4 arithmetics
public func += (lhs: inout Vector4, rhs: Vector4) {
    lhs = lhs + rhs
}

public func -= (lhs: inout Vector4, rhs: Vector4) {
    lhs = lhs - rhs
}

public func *= (lhs: inout Vector4, rhs: Scalar) {
    lhs = lhs * rhs
}

//MARK: Matrix3 arithmetics
public func += (lhs: inout Matrix3, rhs: Matrix3) {
    lhs = lhs + rhs
}

public func -= (lhs: inout Matrix3, rhs: Matrix3) {
    lhs = lhs - rhs
}

public func *= (lhs: inout Matrix3, rhs: Matrix3) {
    lhs = lhs * rhs
}

//MARK: Matrix4 arithmetics
public func += (lhs: inout Matrix4, rhs: Matrix4) {
    lhs = lhs + rhs
}

public func -= (lhs: inout Matrix4, rhs: Matrix4) {
    lhs = lhs - rhs
}

public func *= (lhs: inout Matrix4, rhs: Matrix4) {
    lhs = lhs * rhs
}
