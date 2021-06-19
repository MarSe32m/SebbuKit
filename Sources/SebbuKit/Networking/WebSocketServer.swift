//
//  WebSocketServer.swift
//  
//
//  Created by Sebastian Toivonen on 7.2.2020.
//  Copyright © 2021 Sebastian Toivonen. All rights reserved.
//

//TODO: Implement on Windows
#if !os(Windows)
import WebSocketKit
import NIOWebSocket
import NIO
import NIOSSL
import NIOHTTP1

public protocol WebSocketServerProtocol: AnyObject {
    func shouldUpgrade(requestHead: HTTPRequestHead) -> Bool
    func onConnection(requestHead: HTTPRequestHead, webSocket: WebSocket, channel: Channel)
}

public extension WebSocketServerProtocol {
    func shouldUpgrade(requestHead: HTTPRequestHead) -> Bool { true }
}

public class WebSocketServer {
    public let eventLoopGroup: EventLoopGroup
    public weak var delegate: WebSocketServerProtocol?
    
    private var serverChannelv4: Channel?
    private var serverChannelv6: Channel?
    
    private var sslContext: NIOSSLContext?
    private var isSharedEventLoopGroup: Bool
    public let port: Int
    
    public init(port: Int, tls: TLSConfiguration? = nil, numberOfThreads: Int) throws {
        self.port = port
        self.eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: numberOfThreads)
        self.isSharedEventLoopGroup = false
        if let tls = tls {
            //let configuration = TLSConfiguration.forServer(certificateChain: try NIOSSLCertificate.fromPEMFile("cert.pem").map { .certificate($0) }, privateKey: .file("key.pem"))
            self.sslContext = try NIOSSLContext(configuration: tls)
        }
    }
    
    public init(port: Int, tls: TLSConfiguration? = nil, eventLoopGroup: EventLoopGroup) throws {
        self.port = port
        self.eventLoopGroup = eventLoopGroup
        self.isSharedEventLoopGroup = true
        
        if let tls = tls {
            //let configuration = TLSConfiguration.forServer(certificateChain: try NIOSSLCertificate.fromPEMFile("cert.pem").map { .certificate($0) }, privateKey: .file("key.pem"))
            self.sslContext = try NIOSSLContext(configuration: tls)
        }
    }
    
    public func start() throws {
        let serverBootstrap = bootstrap
        serverChannelv4 = try serverBootstrap.bind(host: "0", port: port).wait()
        serverChannelv6 = try serverBootstrap.bind(host: "::", port: port).wait()
    }
    
    public func stop() throws {
        try serverChannelv4?.close(mode: .all).wait()
        try serverChannelv6?.close(mode: .all).wait()
        print("Websocket server closed successfully!")
        if !isSharedEventLoopGroup {
            try eventLoopGroup.syncShutdownGracefully()
        }
    }
    
    private var bootstrap: ServerBootstrap {
        ServerBootstrap
            .webSocket(on: eventLoopGroup, ssl: sslContext, shouldUpgrade: { [weak self] (head) in
                self?.delegate?.shouldUpgrade(requestHead: head) ?? true
            }, onUpgrade: { [weak self] request, webSocket, channel in
                self?.delegate?.onConnection(requestHead: request, webSocket: webSocket, channel: channel)
            })
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .childChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
    }
}

extension ServerBootstrap {
    static func webSocket(
        on eventLoopGroup: EventLoopGroup,
        ssl sslContext: NIOSSLContext? = nil,
        shouldUpgrade: @escaping (HTTPRequestHead) -> Bool,
        onUpgrade: @escaping (HTTPRequestHead, WebSocket, Channel) -> ()
    ) -> ServerBootstrap {
        ServerBootstrap(group: eventLoopGroup).childChannelInitializer { channel in
            let webSocket = NIOWebSocketServerUpgrader(
                shouldUpgrade: { channel, req in
                    return channel.eventLoop.makeSucceededFuture([:])
                },
                upgradePipelineHandler: { channel, req in
                    return WebSocket.server(on: channel) { ws in
                        if shouldUpgrade(req) {
                            onUpgrade(req, ws, channel)
                        } else {
                            ws.close(code: .policyViolation, promise: nil)
                        }
                    }
                }
            )
            if let sslContext = sslContext {
                let handler = NIOSSLServerHandler(context: sslContext)
                _ = channel.pipeline.addHandler(handler)
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
    }
}

#endif
