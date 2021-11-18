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
    
    func connect(scheme: String, host: String, port: Int, path: String = "/", headers: HTTPHeaders = [:]) async throws -> WebSocket {
        return try await withUnsafeThrowingContinuation({ continuation in
            connect(scheme: scheme, host: host, port: port, path: path, headers: headers, onUpgrade: { ws in
                continuation.resume(returning: ws)
            }).whenFailure({ error in
                continuation.resume(throwing: error)
            })
        })
    }
}
#endif
