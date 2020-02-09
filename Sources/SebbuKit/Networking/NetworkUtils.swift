//
//  NetworkUtils.swift
//  
//
//  Created by Sebastian Toivonen on 9.2.2020.
//  Copyright © 2020 Sebastian Toivonen. All rights reserved.
//

import Foundation


public struct NetworkUtils {
    public static func publicIP() -> String? {
        do {
            guard let url = URL(string: "http://checkip.amazonaws.com") else {
                print("Error creating url")
                return nil
            }
            return try String(contentsOf: url)
        } catch let error {
            print("Error getting IP Address")
            print(error)
        }
        return nil
    }

}
