//
//  NetworkUtils.swift
//  
//
//  Created by Sebastian Toivonen on 9.2.2020.
//  Copyright © 2020 Sebastian Toivonen. All rights reserved.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension String {
    private func isIPv4() -> Bool {
        let items = self.components(separatedBy: ".")
        
        if(items.count != 4) { return false }
        
        for item in items {
            var tmp = 0
            if(item.count > 3 || item.count < 1){
                return false
            }
            
            for char in item {
                if(char < "0" || char > "9"){
                    return false
                }
                
                tmp = tmp * 10 + Int(String(char))!
            }
            
            if(tmp < 0 || tmp > 255){
                return false
            }
            
            if((tmp > 0 && item.first == "0") || (tmp == 0 && item.count > 1)){
                return false
            }
        }
        
        return true
    }

    private func isIPv6() -> Bool {
        let items = self.components(separatedBy: ":")
        if(items.count != 8){
            return false
        }
        
        for item in items{
            if(item.count > 4 || item.count < 1){
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

public struct NetworkUtils {
    private struct IpifyJson: Codable {
        let ip: String
    }

    private static let ipAddressProviders = ["https://api64.ipify.org/?format=json", 
                                             "https://api.ipify.org/?format=json",
                                             "http://myexternalip.com/json"]
    public static let publicIP: String? = {
        for address in ipAddressProviders {
            guard let url = URL(string: address) else {
                continue
            }

            do {
                let data = try Data(contentsOf: url)
                let ipAddress = try JSONDecoder().decode(IpifyJson.self, from: data).ip
                if ipAddress.isIpAddress() {
                    return ipAddress
                }
            } catch let error {
                print("Error retreiving IP address from: \(address)")
                print(error)
            }
        }
        guard let url = URL(string: "http://checkip.amazonaws.com/") else {
            return nil
        }
        do {
            let ipAddress = try String(contentsOf: url)
            if ipAddress.isIpAddress() {
                return ipAddress
            }
        } catch let error {
            print("Error retreiving IP address from: \(url)")
            print(error)
        }
        return nil
    }()
}
