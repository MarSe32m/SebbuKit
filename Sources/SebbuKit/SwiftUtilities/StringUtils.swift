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
