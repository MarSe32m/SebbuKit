//  StringUtils.swift
//
//  Created by Sebastian Toivonen on 17.2.2021.
//
//  Copyright © 2021 Sebastian Toivonen. All rights reserved.

public extension String {
    func trimmed() -> String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    mutating func trim() {
        self = trimmed()
    }
}

public extension Array where Element == UInt8 {
    var hexString: String {
        map { String(format: "%02.2hhx", $0) }.joined()
    }
    
    @inlinable
    static func random(count: Int) -> Self {
        var result = [UInt8]()
        result.reserveCapacity(count)
        for _ in 0..<count {
            result.append(UInt8.random(in: .min ... .max))
        }
        return result
    }
}

public extension StringProtocol {
    var hexBytes: [UInt8] { .init(hex) }
    internal var hex: UnfoldSequence<UInt8, Index> {
        sequence(state: startIndex) { startIndex in
            guard startIndex < self.endIndex else { return nil }
            let endIndex = self.index(startIndex, offsetBy: 2, limitedBy: self.endIndex) ?? self.endIndex
            defer { startIndex = endIndex }
            return UInt8(self[startIndex..<endIndex], radix: 16)
        }
    }
}
