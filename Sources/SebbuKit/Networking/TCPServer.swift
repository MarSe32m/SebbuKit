//
//  TCPServer.swift
//  
//
//  Created by Sebastian Toivonen on 16.6.2021.
//
#if !os(Windows)
import NIO
#if canImport(NIOTransportServices) && canImport(Network)
import NIOTransportServices
#endif

public protocol TCPServerProtocol: AnyObject {
    func connected(_ client: TCPClient)
}

public final class TCPServer {
    
    internal var channel: Channel!
    
    public let eventLoopGroup: EventLoopGroup
    
    public weak var delegate: TCPServerProtocol?
    
    public private(set) var port: Int
    
    private var isSharedEventLoopGroup = false
    
    public init(port: Int, eventLoopGroup: EventLoopGroup) {
        self.port = port
        #if canImport(NIOTransportServices) && canImport(Network)
        assert(eventLoopGroup is NIOTSEventLoopGroup, "On Apple platforms, the event loop group should be a NIOTSEventLoopGroup")
        #endif
        self.eventLoopGroup = eventLoopGroup
        self.isSharedEventLoopGroup = true
    }
    
    public init(port: Int) {
        self.port = port
        #if canImport(NIOTransportServices) && canImport(Network)
        self.eventLoopGroup = NIOTSEventLoopGroup()
        #else
        self.eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        #endif
    }
    
    public final func start() throws {
        #if canImport(NIOTransportServices) && canImport(Network)
        let bootstrap = NIOTSListenerBootstrap(group: eventLoopGroup)
            .childChannelInitializer { channel in
                channel.pipeline.addHandler(BackPressureHandler()).flatMap { v in
                    let receiveHandler = TCPReceiveHandler()
                    let tcpClient = TCPClient(channel: channel, receiveHandler: receiveHandler)
                    self.delegate?.connected(tcpClient)
                    return channel.pipeline.addHandler(receiveHandler)
                }
            }
        #else
        let bootstrap = ServerBootstrap(group: eventLoopGroup)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)

            .childChannelInitializer { channel in
                channel.pipeline.addHandler(BackPressureHandler()).flatMap { v in
                    let receiveHandler = TCPReceiveHandler()
                    let tcpClient = TCPClient(channel: channel, receiveHandler: receiveHandler)
                    self.delegate?.connected(tcpClient)
                    return channel.pipeline.addHandler(receiveHandler)
                }
            }

            .childChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelOption(ChannelOptions.socket(IPPROTO_TCP, TCP_NODELAY), value: 1)
            .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 16)
            .childChannelOption(ChannelOptions.recvAllocator, value: AdaptiveRecvByteBufferAllocator())
        #endif
        
        channel = try bootstrap.bind(host: "0", port: port).wait()
        port = channel.localAddress?.port ?? port
    }
    
    public final func stop() throws {
        try channel.close().wait()
        if !isSharedEventLoopGroup {
            try eventLoopGroup.syncShutdownGracefully()
        }
    }
}
#endif
