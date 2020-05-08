//
//  NetworkUtils.swift
//  
//
//  Created by Sebastian Toivonen on 9.2.2020.
//  Copyright © 2020 Sebastian Toivonen. All rights reserved.
//

import Foundation
import AsyncHTTPClient

public struct NetworkUtils {
    private static let ipAddressProviders = ["https://ipv4.icanhazip.com/", "http://myexternalip.com/raw", "http://checkip.amazonaws.com/"]
    public static func publicIP() -> String? {
        let httpClient = HTTPClient.init(eventLoopGroupProvider: .createNew)
        defer { try! httpClient.syncShutdown() }
        
        for address in ipAddressProviders {
            do {
                let response = try httpClient.get(url: address).wait()
                if var body = response.body {
                    if let ipAddress = body.readString(length: body.readableBytes)?.trimmingCharacters(in: .newlines) {
                        return ipAddress
                    }
                }
            } catch let error {
                print("Error retreiving IP address from: \(address)")
                print(error)
            }
        }
        return nil
    }

}
