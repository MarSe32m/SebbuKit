//
//  NetworkUtils.swift
//  
//
//  Created by Sebastian Toivonen on 9.2.2020.
//  Copyright © 2020 Sebastian Toivonen. All rights reserved.
//

import Foundation

public struct NetworkUtils {
    private static let ipAddressProviders = ["https://api64.ipify.org/", "https://api.ipify.org/", "http://myexternalip.com/raw", "http://checkip.amazonaws.com/"]
    public static let publicIP: String? = {
        for address in ipAddressProviders {
            guard let url = URL(string: address) else {
                continue
            }
            do {
                let ipAddress = try String(contentsOf: url)
                return ipAddress
            } catch let error {
                print("Error retreiving IP address from: \(address)")
                print(error)
            }
        }
        return nil
    }()
}
