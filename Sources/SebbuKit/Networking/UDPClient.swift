//
//  UDPClient.swift
//  
//
//  Created by Sebastian Toivonen on 16.6.2021.
//

//TODO: Remove #if when NIO is available on Windows
#if !os(Windows)
import NIO

public protocol UDPClientProtocol: AnyObject {
    func received(data: [UInt8], address: SocketAddress)
}

public final class UDPClient {
    public let group: EventLoopGroup
    
    @usableFromInline
    internal var channel: Channel!
    
    private let isSharedEventLoopGroup: Bool
    public weak var delegate: UDPClientProtocol? {
        didSet {
            inboundHandler.udpClientProtocol = delegate
        }
    }
    public private(set) var started = false
    private let inboundHandler = UDPInboundHandler()
    
    public var recvBufferSize = 1024 * 1024 {
        didSet {
            if channel != nil {
                _ = channel.setOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_RCVBUF), value: .init(recvBufferSize))
            }
        }
    }
    
    public var sendBufferSize = 1024 * 1024 {
        didSet {
            if channel != nil {
                _ = channel.setOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_SNDBUF), value: .init(sendBufferSize))
            }
        }
    }
    
    public init() {
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        self.isSharedEventLoopGroup = false
    }

    public init(eventLoopGroup: EventLoopGroup) {
        self.group = eventLoopGroup
        self.isSharedEventLoopGroup = true
    }
    
    public func start() throws {
        let bootstrap = DatagramBootstrap(group: group)
            .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_RCVBUF), value: .init(recvBufferSize))
            .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_SNDBUF), value: .init(sendBufferSize))
            .channelInitializer { channel in
                channel.pipeline.addHandler(self.inboundHandler)
            }
        channel = try bootstrap.bind(host: "0", port: 0).wait()
        started = true
    }
    
    public func shutdown() throws {
        try channel.close().wait()
        if !isSharedEventLoopGroup {
            try group.syncShutdownGracefully()
        }
    }
    
    /// Writes the data to the buffer but doesn't send the data to the peer yet
    /// To send the written data, call the flush function
    @inline(__always)
    public final func write(data: [UInt8], address: SocketAddress) {
        guard let buffer = channel?.allocator.buffer(bytes: data) else {
            return
        }
        let envelope = AddressedEnvelope<ByteBuffer>(remoteAddress: address, data: buffer)
        channel.write(envelope, promise: nil)
    }
    
    /// Sends data to a remote peer. In other words writes and flushes the data immediately to the remote peer
    @inline(__always)
    public final func send(data: [UInt8], address: SocketAddress) {
        write(data: data, address: address)
        flush()
    }
    
    /// Flushes the previously written data to the given addresses
    @inline(__always)
    public final func flush() {
        channel.flush()
    }
    
    deinit {
        if let channel = channel {
            if channel.isActive {
                try? shutdown()
            }
        }
    }
}

private final class UDPInboundHandler: ChannelInboundHandler {
    public typealias InboundIn = AddressedEnvelope<ByteBuffer>

    fileprivate weak var udpClientProtocol: UDPClientProtocol?
    
    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let envelope = self.unwrapInboundIn(data)
        if let data = envelope.data.getBytes(at: 0, length: envelope.data.readableBytes) {
            udpClientProtocol?.received(data: data, address: envelope.remoteAddress)
        }
    }

    public func errorCaught(context: ChannelHandlerContext, error: Error) {
        print("UDPInboundHandler: Error in \(#file):\(#function):\(#line): ", error)
        context.close(promise: nil)
    }
}
#endif
