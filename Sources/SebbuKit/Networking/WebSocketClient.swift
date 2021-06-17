//
//  WebSocketClient.swift
//  
//
//  Created by Sebastian Toivonen on 17.6.2021.
//

#if !os(Windows)
import NIO
@_exported import WebSocketKit
import NIOWebSocket
import Dispatch

public extension WebSocketClient {
    func connect(scheme: String, host: String, port: Int, path: String = "/", headers: HTTPHeaders = [:]) throws -> WebSocket {
        var webSocket: WebSocket!
        let semaphore = DispatchSemaphore(value: 0)
        try connect(scheme: scheme, host: host, port: port, path: path, headers: headers) { ws in
            webSocket = ws
            semaphore.signal()
        }.wait()
        semaphore.wait()
        return webSocket
    }
}
#endif
