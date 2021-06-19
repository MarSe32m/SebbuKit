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
    
    internal var ipv4channel: Channel?
    internal var ipv6channel: Channel?
    
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
    
    public final func start(startIpv4: Bool = true, startIpv6: Bool = true) throws {
        if !startIpv4 && !startIpv6 { return }
        
        #if canImport(Network) && canImport(NIOTransportServices)
        // We need to do this because Network doesn't allow binding IPv4 and IPv6 sockets on the same port
        let startIpv6 = startIpv4 && startIpv6 ? false : startIpv6
        #endif
        
        if startIpv4 {
            ipv4channel = try bootstrap.bind(host: "0", port: port).wait()
            //print("ipv4 tcp server started:", ipv4channel!.localAddress!)
        }
        
        if startIpv6 && ipv4channel == nil {
            ipv6channel = try bootstrap.bind(host: "::", port: port).wait()
            //print("ipv6 tcp server started:", ipv6channel!.localAddress!)
        }
        
        port = ipv4channel?.localAddress!.port ?? ipv6channel?.localAddress!.port ?? port
    }
    
    public final func stop() throws {
        try? ipv4channel?.close().wait()
        try? ipv6channel?.close().wait()
        if !isSharedEventLoopGroup {
            try eventLoopGroup.syncShutdownGracefully()
        }
    }
    
    #if canImport(Network) && canImport(NIOTransportServices)
    private var bootstrap: NIOTSListenerBootstrap {
        NIOTSListenerBootstrap(group: eventLoopGroup)
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
    }
    #else
    private var bootstrap: ServerBootstrap {
        ServerBootstrap(group: eventLoopGroup)
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
    }
    #endif
}
#endif
