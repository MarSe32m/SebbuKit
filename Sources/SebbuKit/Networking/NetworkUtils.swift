//
//  NetworkUtils.swift
//  
//
//  Created by Sebastian Toivonen on 9.2.2020.
//  Copyright © 2020 Sebastian Toivonen. All rights reserved.
//

//TODO: Implement this with URLSession
#if !os(Windows)
import Foundation
import AsyncHTTPClient
import NIO

public struct NetworkUtils {
    private static let ipAddressProviders = ["https://ipv4.icanhazip.com/", "http://myexternalip.com/raw", "http://checkip.amazonaws.com/"]
    public static let publicIP: String? = {
        let httpClient = HTTPClient.init(eventLoopGroupProvider: .createNew)
        
        for address in ipAddressProviders {
            do {
                let response = try httpClient.get(url: address, deadline: .now() + .seconds(5)).wait()
                if var body = response.body {
                    if let ipAddress = body.readString(length: body.readableBytes)?.trimmingCharacters(in: .newlines) {
                        try! httpClient.syncShutdown()
                        return ipAddress
                    }
                }
            } catch let error {
                print("Error retreiving IP address from: \(address)")
                print(error)
            }
        }
        try! httpClient.syncShutdown()
        return nil
    }()

}
#endif
