//
//  UDPServer.swift
//
//  Created by Sebastian Toivonen on 24.12.2019.
//  Copyright © 2019 Sebastian Toivonen. All rights reserved.
//
import Foundation
import NIO

public protocol UDPServerProtocol: class {
    func received(data: Data, address: SocketAddress)
}

public final class UDPServer {
    public let port: Int
    private let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    private var channel: Channel!
    
    public weak var delegate: UDPServerProtocol?
    
    public init(port: Int, delegate: UDPServerProtocol? = nil) {
        self.port = port
    }

    public func start() throws {
        let bootstrap = DatagramBootstrap(group: group)
        .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
        .channelInitializer { channel in
            channel.pipeline.addHandler(UDPInboundHandler(server: self))
        }
        do {
            channel = try bootstrap.bind(host: "0", port: port).wait()
        } catch let error {
            print("Error binding to port: \(port)")
            throw error
        }
        if let localAddress = channel.localAddress {
            print("UDP Server started and listening on \(localAddress)")
        }
    }
    
    public func shutdown() {
        do {
            try group.syncShutdownGracefully()
        } catch let error {
            print("Error shutting down eventloop group")
            print(error)
        }
        channel.close(mode: .all, promise: nil)
    }
    
    fileprivate func received(envelope: AddressedEnvelope<ByteBuffer>) {
        let address = envelope.remoteAddress
        if let bytes = envelope.data.getBytes(at: 0, length: envelope.data.readableBytes) {
            self.delegate?.received(data: Data(bytes), address: address)
        }
    }
    
    public final func send(data: Data, address: SocketAddress) {
        var buffer = channel.allocator.buffer(capacity: data.count)
        buffer.writeBytes(data)
        let envelope = AddressedEnvelope<ByteBuffer>(remoteAddress: address, data: buffer)
        _ = channel.writeAndFlush(envelope)
    }
}

private final class UDPInboundHandler: ChannelInboundHandler {
    public typealias InboundIn = AddressedEnvelope<ByteBuffer>
    public typealias OutboundOut = AddressedEnvelope<ByteBuffer>

    private unowned var server: UDPServer
    init(server: UDPServer) {
        self.server = server
    }
    
    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        server.received(envelope: self.unwrapInboundIn(data))
    }

    public func channelReadComplete(context: ChannelHandlerContext) {
        context.flush()
    }
    
    public func errorCaught(context: ChannelHandlerContext, error: Error) {
        print("error in \(#function): ", error)
        context.close(promise: nil)
    }
}
