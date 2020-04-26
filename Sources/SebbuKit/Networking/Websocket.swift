//
//  File.swift
//  
//
//  Created by Sebastian Toivonen on 26.4.2020.
//

import Foundation
import WebSocketKit
import NIOWebSocket
import NIO
import NIOSSL

public protocol WSServerProtocol: class {
    func onConnection(webSocket: WebSocketKit.WebSocket)
    func onDisconnect(webSocket: WebSocketKit.WebSocket)
}

public class WSServer {
    public let eventLoopGroup: MultiThreadedEventLoopGroup
    public weak var delegate: WSServerProtocol?
    
    private var serverChannel: Channel?
    private var sslContext: NIOSSLContext?
    
    public let port: Int
    
    public init(port: Int, tls: TLSConfiguration? = nil, numberOfThreads: Int) throws {
        self.port = port
        self.eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: numberOfThreads)
        
        
        if let tls = tls {
            //let configuration = TLSConfiguration.forServer(certificateChain: try NIOSSLCertificate.fromPEMFile("cert.pem").map { .certificate($0) }, privateKey: .file("key.pem"))
            self.sslContext = try NIOSSLContext(configuration: tls)
        }
    }
    
    public func start() throws {
        serverChannel = try ServerBootstrap(group: eventLoopGroup)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .childChannelInitializer { [unowned self] (channel) in
            let webSocket = NIOWebSocketServerUpgrader(
                shouldUpgrade: { channel, req in
                    return channel.eventLoop.makeSucceededFuture([:])
                },
                upgradePipelineHandler: { channel, req in
                    return WebSocketKit.WebSocket.server(on: channel) { ws in
                        self.delegate?.onConnection(webSocket: ws)
                    }
                }
            )
                if let sslContext = self.sslContext {
                do {
                    let handler = try NIOSSLServerHandler(context: sslContext)
                    _ = channel.pipeline.addHandler(handler)
                } catch let error {
                    print("Failed to create NIOSSLServerHandler for websocket server")
                    print(error)
                }
            }
            return channel.pipeline.configureHTTPServerPipeline(
                withServerUpgrade: (
                    upgraders: [webSocket],
                    completionHandler: { ctx in
                        // complete
                    }
                )
            )
            }
        .childChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .bind(host: "0.0.0.0", port: port).wait()
    }
    
    public func stop() {
        do {
            try eventLoopGroup.syncShutdownGracefully()
        } catch let error {
            print("Failed to stop eventloopgroup")
            print(error)
        }
        
        serverChannel?.close(mode: .all, promise: nil)
    }
    
}
