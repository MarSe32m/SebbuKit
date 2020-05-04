//
//  NativeWebSocket + iOS/macOS.swift
//  
//
//  Created by Sebastian Toivonen on 1.5.2020.
//

#if canImport(Network)
import Starscream
import Foundation

public protocol NativeWebSocketDelegate: class {
    func connected(webSocket: NativeWebSocket)
    func disconnected(webSocket: NativeWebSocket, error: Error?)
    func received(webSocket: NativeWebSocket, data: Data)
    func received(webSocket: NativeWebSocket, text: String)
}

public final class NativeWebSocket: WebSocketDelegate {
    public weak var delegate: NativeWebSocketDelegate?
    
    private var webSocket: WebSocket
    
    public init(url: String, allowSelfSignedCert: Bool = false) {
        guard let host = URL(string: url) else {
            fatalError("Invalid host")
        }
        webSocket = WebSocket(url: host)
        webSocket.delegate = self
        webSocket.disableSSLCertValidation = allowSelfSignedCert
    }
    
    public func connect() {
        webSocket.connect()
    }
    
    public func disconnect() {
        webSocket.disconnect(forceTimeout: 60)
    }
    
    public func websocketDidConnect(socket: WebSocketClient) {
        delegate?.connected(webSocket: self)
    }
    
    public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        delegate?.disconnected(webSocket: self, error: error)
    }
    
    public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        delegate?.received(webSocket: self, text: text)
    }
    
    public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        delegate?.received(webSocket: self, data: data)
    }
    
    public func send(data: Data) {
        webSocket.write(data: data)
    }
    
    public func send(bytes: [UInt8]) {
        webSocket.write(data: Data(bytes))
    }
    
    public func send(text: String) {
        webSocket.write(string: text)
    }
}
#endif
