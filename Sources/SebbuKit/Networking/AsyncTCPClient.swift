//
//  AsyncTCPClient.swift
//  
//
//  Created by Sebastian Toivonen on 3.12.2021.
//

#if !os(Windows)
import NIOCore
import DequeModule

public final class AsyncTCPClient {
    let tcpClient: TCPClient
    
    private var bytesIterator: AsyncStream<[UInt8]>.AsyncIterator
    private let receiveContinuation: AsyncStream<[UInt8]>.Continuation
    
    private var bufferedBytes = Deque<UInt8>()
    
    public init() {
        tcpClient = TCPClient()
        
        var continuation: AsyncStream<[UInt8]>.Continuation!
        bytesIterator = AsyncStream<[UInt8]> { streamContinuation in
            continuation = streamContinuation
        }.makeAsyncIterator()
        receiveContinuation = continuation
        tcpClient.delegate = self
    }
    
    public init(eventLoopGroup: EventLoopGroup) {
        tcpClient = TCPClient(eventLoopGroup: eventLoopGroup)
        var continuation: AsyncStream<[UInt8]>.Continuation!
        bytesIterator = AsyncStream<[UInt8]> { streamContinuation in
            continuation = streamContinuation
        }.makeAsyncIterator()
        receiveContinuation = continuation
        tcpClient.delegate = self
    }
    
    public init(_ tcpClient: TCPClient) {
        self.tcpClient = tcpClient
        
        var continuation: AsyncStream<[UInt8]>.Continuation!
        bytesIterator = AsyncStream<[UInt8]> { streamContinuation in
            continuation = streamContinuation
        }.makeAsyncIterator()
        receiveContinuation = continuation
        tcpClient.delegate = self
    }
    
    public final func connect(address: SocketAddress) async throws {
        try await tcpClient.connect(address: address)
    }
    
    public final func connect(host: String, port: Int) async throws {
        try await tcpClient.connect(host: host, port: port)
    }
    
    public final func disconnect() async throws {
        try await tcpClient.disconnect()
    }
    
    public final func send(_ data: [UInt8]) {
        tcpClient.send(data)
    }
    
    public final func receive() async -> [UInt8]? {
        if !bufferedBytes.isEmpty {
            let buffer = [UInt8](bufferedBytes[bufferedBytes.startIndex..<bufferedBytes.endIndex])
            bufferedBytes.removeFirst(buffer.count)
            return buffer
        }
        return await bytesIterator.next()
    }
    
    public final func receive(count: Int) async -> [UInt8]? {
        if bufferedBytes.count >= count {
            let buffer = [UInt8](bufferedBytes[bufferedBytes.startIndex..<bufferedBytes.index(bufferedBytes.startIndex, offsetBy: count)])
            bufferedBytes.removeFirst(buffer.count)
            return buffer
        }
        
        var bytes: [UInt8] = []
        bytes.reserveCapacity(count)
        bytes.append(contentsOf: bufferedBytes[bufferedBytes.startIndex..<bufferedBytes.endIndex])
        bufferedBytes.removeAll()
        while bytes.count < count {
            guard let nextBuffer = await bytesIterator.next() else {
                bufferedBytes.append(contentsOf: bytes)
                return nil
            }
            let difference = count - bytes.count
            if nextBuffer.count > difference {
                bytes.append(contentsOf: nextBuffer[0..<difference])
                bufferedBytes.append(contentsOf: nextBuffer[difference..<nextBuffer.endIndex])
            } else if nextBuffer.count <= difference {
                bytes.append(contentsOf: nextBuffer)
            }
        }
        return bytes
    }
}

extension AsyncTCPClient: TCPClientProtocol {
    public func received(_ data: [UInt8]) {
        receiveContinuation.yield(data)
    }
    
    public func connected() {}
    
    public func disconnected() {
        receiveContinuation.finish()
    }
}
#endif
