//
//  NetworkUtils.swift
//  
//
//  Created by Sebastian Toivonen on 9.2.2020.
//  Copyright © 2020 Sebastian Toivonen. All rights reserved.
//

import Foundation

public struct NetworkUtils {
    private static let ipAddressProviders = ["http://checkip.amazonaws.com/", "http://myexternalip.com/raw", "https://ipv4.icanhazip.com/"]
    public static func publicIP() -> String? {
        for address in ipAddressProviders {
            do {
                if let url = URL(string: address) {
                    return try String(contentsOf: url)
                } else {
                    print("Error creating url from: \(address)", #file, #line)
                }
            } catch let error {
                print("Error retreiving IP address from: \(address)")
                print(error)
            }
        }
        return nil
    }

}
