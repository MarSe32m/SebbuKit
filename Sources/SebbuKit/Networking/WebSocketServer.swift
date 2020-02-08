//
//  File.swift
//  
//
//  Created by Sebastian Toivonen on 7.2.2020.
//

import Foundation
import NIO
import NIOHTTP1
import NIOWebSocket

public protocol WebSocketServerProtocol: class {
    func connected(socket: WebSocket)
    func disconnected(socket: WebSocket)
}

public final class WebSocketServer {
    private let group: EventLoopGroup
    private let port: Int
    private var channel: Channel!
    weak var delegate: WebSocketServerProtocol?
    
    public init(port: Int, numberOfThreads: Int = 1, delegate: WebSocketServerProtocol? = nil) {
        self.port = port
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: numberOfThreads)
        self.delegate = delegate
    }
    
    public func start() {
        let upgrader = NIOWebSocketServerUpgrader(shouldUpgrade: { (channel: Channel, head: HTTPRequestHead) in channel.eventLoop.makeSucceededFuture(HTTPHeaders()) },
        upgradePipelineHandler: { [unowned self] (channel: Channel, _: HTTPRequestHead) in
            channel.pipeline.addHandler(WebSocketReceiveHandler(webSocketServer: self))
        })
        
        let bootstrap = ServerBootstrap(group: group)
        .serverChannelOption(ChannelOptions.backlog, value: 256)
        .serverChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
        .childChannelInitializer { channel in
            let httpHandler = HTTPHandler()
            let config: NIOHTTPServerUpgradeConfiguration = (
                            upgraders: [ upgrader ],
                            completionHandler: { _ in
                                channel.pipeline.removeHandler(httpHandler, promise: nil)
                            }
                        )
            
            return channel.pipeline.configureHTTPServerPipeline(withServerUpgrade: config).flatMap {
                channel.pipeline.addHandler(httpHandler)
            }
        }

        // Enable SO_REUSEADDR for the accepted Channels
        .childChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
        do {
            // Let's accept connections from all hostnames
            channel = try bootstrap.bind(host: "0", port: port).wait()
        } catch let error {
            print("Error binding to port: \(port)")
            print(error)
        }
        
        guard let localAddress = channel.localAddress else {
            fatalError("Couldn't bind to local address, please check the code!")
        }
        
        print("Server started and listening on \(localAddress)")
    }
    
    public func shutdown() {
        do {
            try group.syncShutdownGracefully()
        } catch let error {
            print("Error shutting down eventloop group")
            print(error)
        }
        channel.close(mode: .all, promise: nil)
        print("Server closed")
    }
}

fileprivate let websocketResponse = """
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>WebSockets?</title>
    <script>
        var wsconnection = new WebSocket("ws://80.221.64.248:10020");
        wsconnection.onmessage = function (msg) {
            var element = document.createElement("p");
            element.innerHTML = msg.data;
            var textDiv = document.getElementById("websocket-stream");
            textDiv.insertBefore(element, null);
        };
    </script>
  </head>
  <body>
    <h1>WebSockets?/h1>
    <div id="websocket-stream"></div>
  </body>
</html>
"""

fileprivate final class HTTPHandler: ChannelInboundHandler, RemovableChannelHandler {
    typealias InboundIn = HTTPServerRequestPart
    typealias OutboundOut = HTTPServerResponsePart

    private var responseBody: ByteBuffer!
    
    func handlerAdded(context: ChannelHandlerContext) {
        var buffer = context.channel.allocator.buffer(capacity: websocketResponse.utf8.count)
        buffer.writeString(websocketResponse)
        self.responseBody = buffer
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let reqPart = self.unwrapInboundIn(data)

        // We're not interested in request bodies here: we're just serving up GET responses
        // to get the client to initiate a websocket request.
        guard case .head(let head) = reqPart else {
            return
        }
        
        guard case .GET = head.method else {
            self.respond405(context: context)
            return
        }
        var headers = HTTPHeaders()
        headers.add(name: "Content-Length", value: String(self.responseBody.readableBytes))
        headers.add(name: "Connection", value: "close")
        let responseHead = HTTPResponseHead(version: .init(major: 1, minor: 1),
                                    status: .ok,
                                    headers: headers)
        context.write(self.wrapOutboundOut(.head(responseHead)), promise: nil)
        context.write(self.wrapOutboundOut(.body(.byteBuffer(self.responseBody))), promise: nil)
        context.write(self.wrapOutboundOut(.end(nil))).whenComplete { (_: Result<Void, Error>) in
            context.close(promise: nil)
        }
        
        context.flush()
    }

    private func respond405(context: ChannelHandlerContext) {
        var headers = HTTPHeaders()
        headers.add(name: "Connection", value: "close")
        headers.add(name: "Content-Length", value: "0")
        let head = HTTPResponseHead(version: .init(major: 1, minor: 1),
                                    status: .methodNotAllowed,
                                    headers: headers)
        context.write(self.wrapOutboundOut(.head(head)), promise: nil)
        context.write(self.wrapOutboundOut(.end(nil))).whenComplete { (_: Result<Void, Error>) in
            context.close(promise: nil)
        }
        context.flush()
    }
}

fileprivate final class WebSocketReceiveHandler: ChannelInboundHandler {
    typealias InboundIn = WebSocketFrame
    typealias OutboundOut = WebSocketFrame

    private var awaitingClose: Bool = false
    private weak var webSocketServer: WebSocketServer?
    private var pingSequence = 0
    private let uuid = UUID()
    private var webSocket: WebSocket?
    
    init(webSocketServer: WebSocketServer) {
        self.webSocketServer = webSocketServer
    }
    
    public func handlerAdded(context: ChannelHandlerContext) {
        self.webSocket = WebSocket(channel: context.channel)
        webSocketServer?.delegate?.connected(socket: webSocket!)
        self.sendPing(context: context)
    }
    
    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let frame = self.unwrapInboundIn(data)
        
        switch frame.opcode {
        case .connectionClose:
            self.receivedClose(context: context, frame: frame)
        case .ping:
            self.pong(context: context, frame: frame)
        case .pong:
            webSocket?.lastPong = Date()
        case .text:
            var data = frame.unmaskedData
            let text = data.readString(length: data.readableBytes) ?? ""
            self.webSocket?.textClosure?(text)
        case .binary:
            let unmasked = frame.unmaskedData
            if let data = unmasked.getBytes(at: 0, length: unmasked.readableBytes) {
                self.webSocket?.dataClosure?(Data(data))
            } else {
                print("Failed to read data from byte buffer")
            }
        case .continuation:
            break
        default:
            self.closeOnError(context: context)
        }
    }

    public func channelReadComplete(context: ChannelHandlerContext) {
        context.flush()
    }

    private func sendPing(context: ChannelHandlerContext) {
        let testFrameData = "\(pingSequence)"
        pingSequence += 1
        var buffer = context.channel.allocator.buffer(capacity: testFrameData.utf8.count)
        buffer.writeString(testFrameData)
        let frame = WebSocketFrame(fin: true, opcode: .ping, data: buffer)
        context.writeAndFlush(self.wrapOutboundOut(frame)).map {
            context.eventLoop.scheduleTask(in: .seconds(5), { self.sendPing(context: context) })
        }.whenFailure { (_: Error) in
            context.close(promise: nil)
        }
    }

    private func receivedClose(context: ChannelHandlerContext, frame: WebSocketFrame) {
        if awaitingClose {
            context.close(promise: nil)
        } else {
            var data = frame.unmaskedData
            let closeDataCode = data.readSlice(length: 2) ?? context.channel.allocator.buffer(capacity: 0)
            let closeFrame = WebSocketFrame(fin: true, opcode: .connectionClose, data: closeDataCode)
            _ = context.write(self.wrapOutboundOut(closeFrame)).map { () in
                context.close(promise: nil)
            }
        }
    }

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
        var data = context.channel.allocator.buffer(capacity: 2)
        data.write(webSocketErrorCode: .protocolError)
        let frame = WebSocketFrame(fin: true, opcode: .connectionClose, data: data)
        context.writeAndFlush(self.wrapOutboundOut(frame)).whenComplete { (_: Result<Void, Error>) in
            context.close(mode: .output, promise: nil)
        }
        awaitingClose = true
    }
    
    deinit {
        guard let webSocket = webSocket else {
            fatalError("Someone nilled the webSocket?")
        }
        webSocketServer?.delegate?.disconnected(socket: webSocket)
        webSocket.dataClosure = nil
        webSocket.textClosure = nil
    }
}

public final class WebSocket: Equatable {
    private let channel: Channel
    public var remoteIpAddress: String? {
        return channel.remoteAddress?.ipAddress
    }
    public var remotePort: Int? {
        return channel.remoteAddress?.port
    }
    
    private let uuid = UUID()
    
    fileprivate var lastPong = Date.distantPast
    
    public var wantsToDisconnect: Bool {
        //If 4 ping packets hasn't arrived, then there must be something going on
        return lastPong.timeIntervalSinceNow < -20
    }
    fileprivate var dataClosure: ((_ data: Data) -> Void)?
    fileprivate var textClosure: ((_ text: String) -> Void)?
    
    fileprivate init(channel: Channel) {
        self.channel = channel
    }
    
    public func onData(closure: @escaping ((_ data: Data) -> Void)) {
        dataClosure = closure
    }
    
    public func onText(closure: @escaping ((_ data: String) -> Void)) {
        textClosure = closure
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
    
    public final func sendPing() {
        let testFrameData = "Hello World"
        var buffer = channel.allocator.buffer(capacity: testFrameData.utf8.count)
        buffer.writeString(testFrameData)
        let frame = WebSocketFrame(fin: true, opcode: .ping, data: buffer)
        channel.writeAndFlush(frame, promise: nil)
    }
    
    public final func close() {
        var data = channel.allocator.buffer(capacity: "Bye".utf8.count)
        data.writeString("Bye")
        let frame = WebSocketFrame(fin: true, opcode: .connectionClose, data: data)
        channel.writeAndFlush(frame).whenComplete { (_: Result<Void, Error>) in
            _ = self.channel.close()
        }
    }
    
    
    public static func == (lhs: WebSocket, rhs: WebSocket) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
}
