//  Copyright © 2021 Sebastian Toivonen. All rights reserved.
@_exported import Foundation
@_exported import GLMSwift

#if os(Linux)
@_exported import Dispatch
@_exported import FoundationNetworking
@_exported import Glibc
#elseif os(Windows)
@_exported import Dispatch
@_exported import FoundationNetworking
@_exported import CRT
#endif

@inlinable
public func slowEquals(_ a: [UInt8], _ b: [UInt8]) -> Bool {
    var diff = a.count ^ b.count
    for i in 0..<min(a.count, b.count) {
        diff |= Int(a[i] ^ b[i])
    }
    return diff == 0
}
