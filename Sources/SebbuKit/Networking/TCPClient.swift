//
//  TCPClient.swift
//  
//
//  Created by Sebastian Toivonen on 16.6.2021.
//
#if !os(Windows)
import NIO
#if canImport(NIOTransportServices) && canImport(Network)
import NIOTransportServices
#endif

public protocol TCPClientProtocol: AnyObject {
    func received(_ data: [UInt8])
    func connected()
    func diconnected()
}

public final class TCPClient {
    internal var receiveHandler: TCPReceiveHandler
    
    public weak var delegate: TCPClientProtocol? {
        didSet {
            receiveHandler.delegate = delegate
        }
    }
    
    @usableFromInline
    internal var channel: Channel!
    
    private var targetAddress: SocketAddress!
    public let eventLoopGroup: EventLoopGroup
    
    private var isSharedEventLoopGroup = false
    
    public init(address: SocketAddress) {
        self.targetAddress = address
        #if canImport(NIOTransportServices) && canImport(Network)
        self.eventLoopGroup = NIOTSEventLoopGroup()
        #else
        self.eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        #endif
        self.receiveHandler = TCPReceiveHandler()
    }
    
    public init(address: SocketAddress, eventLoopGroup: EventLoopGroup) {
        self.targetAddress = address
        #if canImport(NIOTransportServices) && canImport(Network)
        assert(eventLoopGroup is NIOTSEventLoopGroup, "On Apple platforms, the event loop group should be a NIOTSEventLoopGroup")
        #endif
        self.eventLoopGroup = eventLoopGroup
        self.receiveHandler = TCPReceiveHandler()
        self.isSharedEventLoopGroup = true
    }
    
    internal init(channel: Channel, receiveHandler: TCPReceiveHandler) {
        eventLoopGroup = channel.eventLoop
        self.channel = channel
        self.receiveHandler = receiveHandler
        self.isSharedEventLoopGroup = true
    }
    
    @inline(__always)
    public final func send(_ bytes: [UInt8]) {
        let buffer = channel.allocator.buffer(bytes: bytes)
        channel.writeAndFlush(buffer, promise: nil)
    }
    
    @inline(__always)
    public final func write(_ bytes: [UInt8]) {
        let buffer = channel.allocator.buffer(bytes: bytes)
        channel.write(buffer, promise: nil)
    }
    
    @inline(__always)
    public final func flush() {
        channel.flush()
    }
    
    public final func connect() throws {
        if channel != nil { return }
        #if canImport(NIOTransportServices) && canImport(Network)
        let bootstrap = NIOTSConnectionBootstrap(group: eventLoopGroup)
            .connectTimeout(.seconds(10))
            .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .channelOption(ChannelOptions.socket(IPPROTO_TCP, TCP_NODELAY), value: 1)
            .channelInitializer { channel in
                channel.pipeline.addHandler(self.receiveHandler)
            }
        #else
        let bootstrap = ClientBootstrap(group: eventLoopGroup)
            .connectTimeout(.seconds(10))
            .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .channelOption(ChannelOptions.socket(IPPROTO_TCP, TCP_NODELAY), value: 1)
            .channelInitializer { channel in
                channel.pipeline.addHandler(self.receiveHandler)
            }
        #endif
        channel = try bootstrap.connect(to: targetAddress).wait()
    }
    
    public final func diconnect() throws {
        try channel.close().wait()
        if !isSharedEventLoopGroup {
            try eventLoopGroup.syncShutdownGracefully()
        }
        channel = nil
    }
}

internal final class TCPReceiveHandler: ChannelInboundHandler {
    public typealias InboundIn = ByteBuffer
    public typealias OutboundOut = ByteBuffer

    weak var delegate: TCPClientProtocol?

    func channelRegistered(context: ChannelHandlerContext) {
        delegate?.connected()
    }
    
    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let buffer = self.unwrapInboundIn(data)
        if let bytes = buffer.getBytes(at: 0, length: buffer.readableBytes) {
            delegate?.received(bytes)
        }
    }
    
    func channelUnregistered(context: ChannelHandlerContext) {
        delegate?.diconnected()
    }

    public func errorCaught(context: ChannelHandlerContext, error: Error) {
        print("Error caught in \(#file) \(#line): ", error)
        context.close(promise: nil)
    }
}
#endif
