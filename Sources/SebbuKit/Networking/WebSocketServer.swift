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
    func shouldUpgrade(requestHead: HTTPRequestHead) -> (shouldUpgrade: Bool, headers: HTTPHeaders)
    func onConnection(requestHead: HTTPRequestHead, webSocket: WebSocket, channel: Channel)
}

public extension WebSocketServerProtocol {
    func shouldUpgrade(requestHead: HTTPRequestHead) -> (shouldUpgrade: Bool, headers: HTTPHeaders) { (true, [:]) }
}

public class WebSocketServer {
    public let eventLoopGroup: EventLoopGroup
    public weak var delegate: WebSocketServerProtocol?
    
    private var serverChannel: Channel?
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
        serverChannel = try ServerBootstrap
            .webSocket(on: eventLoopGroup, ssl: sslContext, shouldUpgrade: { [weak self] (head) in
                self?.delegate?.shouldUpgrade(requestHead: head) ?? (true, [:])
            }, onUpgrade: { [weak self] request, webSocket, channel in
                self?.delegate?.onConnection(requestHead: request, webSocket: webSocket, channel: channel)
            })
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .childChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .bind(host: "0", port: port).wait()
    }
    
    public func stop() throws {
        _ = serverChannel?.closeFuture.always({ (result) in
        switch result {
        case .success(_):
            print("WebSocket Server closed successfully")
        case .failure(let error):
            print("Error upon closing WebSocket Server")
            print(error)
        }
        })
        serverChannel?.close(mode: .all, promise: nil)
        
        if !isSharedEventLoopGroup {
            try eventLoopGroup.syncShutdownGracefully()
        }
    }
}

extension ServerBootstrap {
    static func webSocket(
        on eventLoopGroup: EventLoopGroup,
        ssl sslContext: NIOSSLContext? = nil,
        shouldUpgrade: @escaping (HTTPRequestHead) -> (Bool, HTTPHeaders),
        onUpgrade: @escaping (HTTPRequestHead, WebSocket, Channel) -> ()
    ) -> ServerBootstrap {
        ServerBootstrap(group: eventLoopGroup).childChannelInitializer { channel in
            let webSocket = NIOWebSocketServerUpgrader(
                shouldUpgrade: { channel, req in
                    let shouldBeUpgraded = shouldUpgrade(req)
                    if shouldBeUpgraded.0 {
                        return channel.eventLoop.makeSucceededFuture(shouldBeUpgraded.1)
                    } else {
                        channel.close()
                        return channel.eventLoop.makeSucceededFuture(nil)
                    }
                },
                upgradePipelineHandler: { channel, req in
                    return WebSocket.server(on: channel) { ws in
                        onUpgrade(req, ws, channel)
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
