//
//  NativeWebSocket + iOS/macOS.swift
//  
//
//  Created by Sebastian Toivonen on 1.5.2020.
//

#if canImport(Network)
import Foundation
import Network

public protocol WebSocketConnection {
    func send(text: String)
    func send(data: Data)
    func connect()
    func disconnect()
    var delegate: WebSocketConnectionDelegate? {
        get
        set
    }
}

public protocol WebSocketConnectionDelegate: class {
    func onConnected(connection: WebSocketConnection)
    func onDisconnected(connection: WebSocketConnection, error: Error?)
    func onError(connection: WebSocketConnection, error: Error)
    func onMessage(connection: WebSocketConnection, text: String)
    func onMessage(connection: WebSocketConnection, data: Data)
}

extension WebSocketConnectionDelegate {
    func onMessage(connection: WebSocketConnection, data: Data) {}
}

public final class NativeWebSocket: NSObject, WebSocketConnection, URLSessionWebSocketDelegate {
    public weak var delegate: WebSocketConnectionDelegate?
    private var webSocketTask: URLSessionWebSocketTask!
    private var urlSession: URLSession!
    private let delegateQueue = OperationQueue()
    private var pingTimer: Timer?
    
    public init(url: URL, autoConnect: Bool = false) {
        super.init()
        urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: delegateQueue)
        webSocketTask = urlSession.webSocketTask(with: url)
        if autoConnect {
            connect()
        }
    }
    
    public final func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        self.delegate?.onConnected(connection: self)
    }
    
    public final func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        self.delegate?.onDisconnected(connection: self, error: nil)
    }
    
    public final func connect() {
        webSocketTask.resume()
        listen()
    }
    
    public final func disconnect() {
        webSocketTask.cancel(with: .normalClosure, reason: nil)
        pingTimer?.invalidate()
    }
    
    private final func listen()  {
        webSocketTask.receive { result in
            switch result {
            case .failure(let error):
                self.delegate?.onError(connection: self, error: error)
            case .success(let message):
                switch message {
                case .string(let text):
                    self.delegate?.onMessage(connection: self, text: text)
                case .data(let data):
                    self.delegate?.onMessage(connection: self, data: data)
                @unknown default:
                    fatalError()
                }
            }
            self.listen()
        }
    }
    
    public final func sendPing() {
        webSocketTask.sendPing { (error) in
            if let error = error {
                print("Sending PING failed: \(error)")
            }
            self.pingTimer = Timer.scheduledTimer(withTimeInterval: 25.0, repeats: true) { time in
                self.sendPing()
            }
        }
    }
    
    public final func send(text: String) {
        webSocketTask.send(URLSessionWebSocketTask.Message.string(text)) { error in
            if let error = error {
                self.delegate?.onError(connection: self, error: error)
            }
        }
    }
    
    public final func send(data: Data) {
        webSocketTask.send(URLSessionWebSocketTask.Message.data(data)) { error in
            if let error = error {
                self.delegate?.onError(connection: self, error: error)
            }
        }
    }
}
#endif
