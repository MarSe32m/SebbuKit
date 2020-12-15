//  Copyright © 2020 Sebastian Toivonen. All rights reserved.
@_exported import Foundation
#if os(Linux)
@_exported import FoundationNetworking
@_exported import Dispatch
@_exported import Glibc
#elseif os(Windows)
@_exported import FoundationNetworking
@_exported import Dispatch
@_exported import CRT
#endif

#if !os(Windows)
//TODO: Replace with my own math library
@_exported import VectorMath
#endif

