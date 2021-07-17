//  StringUtils.swift
//
//  Created by Sebastian Toivonen on 17.2.2021.
//
//  Copyright © 2021 Sebastian Toivonen. All rights reserved.

public extension String {
    func isIPv4() -> Bool {
        let items = self.components(separatedBy: ".")
        
        if items.count != 4 { return false }
        
        for item in items {
            var tmp = 0
            if item.count > 3 || item.count < 1 {
                return false
            }
            
            for char in item {
                if char < "0" || char > "9" {
                    return false
                }
                
                tmp = tmp * 10 + Int(String(char))!
            }
            
            if tmp < 0 || tmp > 255 {
                return false
            }
            
            if (tmp > 0 && item.first == "0") || (tmp == 0 && item.count > 1) {
                return false
            }
        }
        
        return true
    }

    func isIPv6() -> Bool {
        let items = self.components(separatedBy: ":")
        if items.count != 8 {
            return false
        }
        
        for item in items {
            if item.count > 4 || item.count < 1 {
                return false;
            }
            
            for char in item.lowercased() {
                if((char < "0" || char > "9") && (char < "a" || char > "f")){
                    return false
                }
            }
        }
        return true
    }

    func isIpAddress() -> Bool { return self.isIPv6() || self.isIPv4() }
}

public extension Array where Element == UInt8 {
    var hexString: String {
        map { String(format: "%02.2hhx", $0) }.joined()
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
