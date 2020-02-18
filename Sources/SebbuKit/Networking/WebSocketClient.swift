//
//  WebSocketClient.swift
//  
//
//  Created by Sebastian Toivonen on 8.2.2020.
//  Copyright © 2020 Sebastian Toivonen. All rights reserved.
//

import Foundation
import NIO
import NIOWebSocket
import NIOHTTP1
import NIOSSL
import NIOTLS

public protocol WebSocketClientDelegate: class {
    func received(text: String)
    func received(data: Data)
    func disconnected()
}

public final class WebSocketClient {
    public private(set) var lastPong = Date()
    private let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    private let tls: Bool
    public let port: Int
    public let hostname: String
    private var channel: Channel!
    
    public weak var delegate: WebSocketClientDelegate?
    
    private var textClosure: ((_ text: String) -> Void)?
    private var dataClosure: ((_ data: Data) -> Void)?
    private var disconnectClosure: (() -> Void)?
    
    public init(port: Int, hostname: String, tls: Bool = false) {
        self.port = port
        self.hostname = hostname
        self.tls = tls
    }
    
    public final func start() throws {
        let configuration:TLSConfiguration = TLSConfiguration.forClient() //TODO: Change this in prod!
        var sslContext: NIOSSLContext?
        if tls {
            sslContext = try NIOSSLContext(configuration: configuration)
        }
        let bootstrap = ClientBootstrap(group: group)
            .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .channelInitializer { channel in
                
                let httpHandler = HTTPInitialRequestHandler()
                
                let websocketUpgrader = NIOWebSocketClientUpgrader(requestKey: "OfS0wDaT5NoxF2gqm7Zj2YtetzM=",
                                                                   upgradePipelineHandler: { (channel: Channel, _: HTTPResponseHead) in
                                                                    
                                                                    return channel.pipeline.addHandler(WebSocketReceiveHandler(webSocketClient: self))
                })
                
                let config: NIOHTTPClientUpgradeConfiguration = (
                    upgraders: [ websocketUpgrader ],
                    completionHandler: { _ in
                        channel.pipeline.removeHandler(httpHandler, promise: nil)
                })
                if let sslContext = sslContext, self.tls {
                    let clientHandler = try! NIOSSLClientHandler(context: sslContext, serverHostname: nil)
                    _ = channel.pipeline.addHandler(clientHandler)
                }
                return channel.pipeline.addHTTPClientHandlers(withClientUpgrade: config).flatMap {
                    channel.pipeline.addHandler(httpHandler)
                }
        }
        do {
            channel = try bootstrap.connect(host: hostname, port: port).wait()
        } catch let error {
            print("Error binding to host: \(hostname), port: \(port)")
            throw error
        }
        
        guard let localAddress = channel.localAddress else {
            print("Couldn't bind to local address, please check the code!")
            return
        }
        
        print("Client started on \(localAddress)")
    }
    
    public final func onText(closure: @escaping (_ text: String) -> Void) {
        self.textClosure = closure
    }
    
    public final func onData(closure: @escaping (_ dat: Data) -> Void) {
        self.dataClosure = closure
    }
    
    public final func onDisconnect(closure: @escaping () -> Void) {
        self.disconnectClosure = closure
    }
    
    fileprivate final func received(text: String) {
        delegate?.received(text: text)
        textClosure?(text)
    }
    
    fileprivate final func received(data: Data) {
        delegate?.received(data: data)
        dataClosure?(data)
    }
    
    fileprivate final func disconnected() {
        delegate?.disconnected()
        disconnectClosure?()
    }
    
    public final func send(data: Data) {
        var buffer = channel.allocator.buffer(capacity: data.count)
        buffer.writeBytes(data)
        let frame = WebSocketFrame(fin: true, opcode: WebSocketOpcode.binary, data: buffer)
        channel.writeAndFlush(frame, promise: nil)
    }
    
    public final func send(text: String) {
        var buffer = channel.allocator.buffer(capacity: text.utf8.count)
        buffer.writeString(text)
        let frame = WebSocketFrame(fin: true, opcode: WebSocketOpcode.text, data: buffer)
        channel.writeAndFlush(frame, promise: nil)
    }
    
    public final func ping() {
        let testFrameData = "Hello World"
        var buffer = channel.allocator.buffer(capacity: testFrameData.utf8.count)
        buffer.writeString(testFrameData)
        let frame = WebSocketFrame(fin: true, opcode: .ping, data: buffer)
        channel.writeAndFlush(frame, promise: nil)
    }
    
    public final func shutdown() {
        var data = channel.allocator.buffer(capacity: 2)
        data.write(webSocketErrorCode: .normalClosure)
        let frame = WebSocketFrame(fin: true, opcode: .connectionClose, data: data)
        channel.writeAndFlush(frame).whenComplete { (_: Result<Void, Error>) in
            self.channel.close(mode: .all, promise: nil)
        }
        disconnected()
        do {
            try group.syncShutdownGracefully()
        } catch let error {
            print("Error shutting down eventloop group")
            print(error)
        }
        textClosure = nil
        dataClosure = nil
        disconnectClosure = nil
    }
    
}

// The HTTP handler to be used to initiate the request.
// This initial request will be adapted by the WebSocket upgrader to contain the upgrade header parameters.
// Channel read will only be called if the upgrade fails.
private final class HTTPInitialRequestHandler: ChannelInboundHandler, RemovableChannelHandler {
    public typealias InboundIn = HTTPClientResponsePart
    public typealias OutboundOut = HTTPClientRequestPart
    
    public func channelActive(context: ChannelHandlerContext) {
        // We are connected. It's time to send the message to the server to initialize the upgrade dance.
        var headers = HTTPHeaders()
        headers.add(name: "Content-Type", value: "text/plain; charset=utf-8")
        headers.add(name: "Content-Length", value: "\(0)")
        
        let requestHead = HTTPRequestHead(version: HTTPVersion(major: 1, minor: 1),
                                          method: .GET,
                                          uri: "/",
                                          headers: headers)
        
        context.write(self.wrapOutboundOut(.head(requestHead)), promise: nil)
        
        let emptyBuffer = context.channel.allocator.buffer(capacity: 0)
        let body = HTTPClientRequestPart.body(.byteBuffer(emptyBuffer))
        context.write(self.wrapOutboundOut(body), promise: nil)
        
        context.writeAndFlush(self.wrapOutboundOut(.end(nil)), promise: nil)
    }
    
    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        
        let clientResponse = self.unwrapInboundIn(data)
        
        print("WebSocket upgrade failed")
        
        switch clientResponse {
        case .head(let responseHead):
            print("Received status: \(responseHead.status)")
        case .body(var byteBuffer):
            if let string = byteBuffer.readString(length: byteBuffer.readableBytes) {
                print("Received: '\(string)' back from the server.")
            } else {
                print("Received the line back from the server.")
            }
        case .end:
            print("Closing channel.")
            context.close(promise: nil)
        }
    }
    
    public func errorCaught(context: ChannelHandlerContext, error: Error) {
        print("error: ", error)
        
        // As we are not really interested getting notified on success or failure
        // we just pass nil as promise to reduce allocations.
        context.close(promise: nil)
    }
}

private final class WebSocketReceiveHandler: ChannelInboundHandler {
    typealias InboundIn = WebSocketFrame
    typealias OutboundOut = WebSocketFrame
    
    private let testFrameData: String = "Hello World"
    public private(set) var lastPong = Date.distantPast
    private let webSocketClient: WebSocketClient
    
    init(webSocketClient: WebSocketClient) {
        self.webSocketClient = webSocketClient
    }
    // This is being hit, channel active won't be called as it is already added.
    public func handlerAdded(context: ChannelHandlerContext) {
        self.ping(context: context)
    }

    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let frame = self.unwrapInboundIn(data)
        
        switch frame.opcode {
        case .connectionClose:
            self.receivedClose(context: context, frame: frame)
        case.ping:
            self.pong(context: context, frame: frame)
        case .pong:
            lastPong = Date()
        case .text:
            var data = frame.unmaskedData
            let text = data.readString(length: data.readableBytes) ?? ""
            webSocketClient.received(text: text)
        case .continuation:
            print("Continuation opcode not handled on WebSocketClient yet")
        case .binary:
            let unmasked = frame.unmaskedData
            if let data = unmasked.getBytes(at: 0, length: unmasked.readableBytes) {
                webSocketClient.received(data: Data(data))
            } else {
                print("Failed to get data from bytebuffer")
            }
            break
        default:
            // Unknown frames are errors.
            self.closeOnError(context: context)
        }
    }
    
    public func channelReadComplete(context: ChannelHandlerContext) {
        context.flush()
    }

    private func receivedClose(context: ChannelHandlerContext, frame: WebSocketFrame) {
        context.close(promise: nil)
        webSocketClient.disconnected()
    }
    /// Send a ping
    private func ping(context: ChannelHandlerContext) {
        var buffer = context.channel.allocator.buffer(capacity: self.testFrameData.utf8.count)
        buffer.writeString(self.testFrameData)
        let frame = WebSocketFrame(fin: true, opcode: .ping, data: buffer)
        context.write(self.wrapOutboundOut(frame), promise: nil)
    }
    
    /// Respond to a ping message with the same frame as pong
    private func pong(context: ChannelHandlerContext, frame: WebSocketFrame) {
        var frameData = frame.data
        let maskingKey = frame.maskKey

        if let maskingKey = maskingKey {
            frameData.webSocketUnmask(maskingKey)
        }

        let responseFrame = WebSocketFrame(fin: true, opcode: .pong, data: frameData)
        context.write(self.wrapOutboundOut(responseFrame), promise: nil)
    }
    
    private func closeOnError(context: ChannelHandlerContext) {
        webSocketClient.disconnected()
        // We have hit an error, we want to close. We do that by sending a close frame and then
        // shutting down the write side of the connection. The server will respond with a close of its own.
        var data = context.channel.allocator.buffer(capacity: 2)
        data.write(webSocketErrorCode: .protocolError)
        let frame = WebSocketFrame(fin: true, opcode: .connectionClose, data: data)
        context.write(self.wrapOutboundOut(frame)).whenComplete { (_: Result<Void, Error>) in
            context.close(mode: .output, promise: nil)
        }
    }
}
