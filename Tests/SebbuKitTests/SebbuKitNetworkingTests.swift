//
//  SebbuKitNetworkingTests.swift
//  
//
//  Created by Sebastian Toivonen on 17.6.2021.
//
#if !os(Windows)
import XCTest
import Foundation
import NIO
import NIOHTTP1
import SebbuKit

let testData = (0..<128).map { _ in UInt8.random(in: .min ... .max) }

final class SebbuKitNetworkingTests: XCTestCase {
    
    func testUDPClientServer() throws {
        class ServerDelegate: UDPServerProtocol {
            unowned var udpServer: UDPServer!
            
            func received(data: [UInt8], address: SocketAddress) {
                XCTAssertEqual(testData, data)
                udpServer.send(data: data, address: address)
            }
        }
        
        class ClientDelegate: UDPClientProtocol {
            var successfulReceives = 0
            func received(data: [UInt8], address: SocketAddress) {
                XCTAssertEqual(testData, data)
                successfulReceives += 1
            }
        }
        
        let serverDelegate = ServerDelegate()
        let server = UDPServer(port: 25567)
        server.delegate = serverDelegate
        serverDelegate.udpServer = server
        server.recvBufferSize = 1024 * 1024
        server.sendBufferSize = 1024 * 1024
        try server.start()
        
        let clientDelegate = ClientDelegate()
        let client = UDPClient()
        client.delegate = clientDelegate
        try client.start()
        
        while clientDelegate.successfulReceives < 1000 {
            client.send(data: testData, address: try! .init(ipAddress: "127.0.0.1", port: 25567))
            Thread.sleep(forTimeInterval: 0.001)
        }
        try server.shutdown()
        try client.shutdown()
    }
    
    func testTCPClientServer() throws {
        class ServerHandler: TCPServerProtocol {
            var clients = [TCPClient]()
            var handlers = [ServerClientHandler]()
            func connected(_ client: TCPClient) {
                clients.append(client)
                let handler = ServerClientHandler()
                handlers.append(handler)
                client.delegate = handler
                client.eventLoopGroup.next().scheduleTask(deadline: NIODeadline.now() + .milliseconds(1)) {
                    for _ in 0..<10_000 {
                        client.send([1,1,1,1,1])
                    }
                }
                
            }
        }
        
        class ServerClientHandler: TCPClientProtocol {
            var totalReceivedData = [UInt8]()
            let expectedData: [UInt8] = (0..<10_000).flatMap {_ in [2,2,2,2,2]}
            var isConnected = false
            
            func connected() {
                XCTAssertFalse(isConnected)
                isConnected = true
                totalReceivedData.reserveCapacity(10_000 * 5)
            }
            
            func diconnected() {
                XCTAssertTrue(isConnected)
                isConnected = false
                print("Server Client: Disconnected from server!")
                XCTAssertEqual(totalReceivedData.count, expectedData.count)
                XCTAssertEqual(totalReceivedData, expectedData)
            }
            
            func received(_ data: [UInt8]) {
                totalReceivedData += data
            }
        }
        
        class ClientHandler: TCPClientProtocol {
            var totalReceivedData = [UInt8]()
            let expectedData: [UInt8] = (0..<10_000).flatMap {_ in [1,1,1,1,1]}
            var isConnected = false
            func connected() {
                XCTAssertFalse(isConnected)
                isConnected = true
                totalReceivedData.reserveCapacity(10000 * 5)
            }
            
            func diconnected() {
                XCTAssertTrue(isConnected)
                isConnected = false
                
                print("Client: Disconnected from server!")
                XCTAssertEqual(totalReceivedData.count, expectedData.count)
                XCTAssertEqual(totalReceivedData, expectedData)
            }
            
            func received(_ data: [UInt8]) {
                totalReceivedData += data
            }
        }
        
        let serverDelegate = ServerHandler()
        
        let server = TCPServer(port: 25565)
        server.delegate = serverDelegate
        try server.start()
        
        let clientDelegate = ClientHandler()
        let client = TCPClient()
        client.delegate = clientDelegate
        try client.connect(host: "127.0.0.1", port: 25565)
        Thread.sleep(forTimeInterval: 1)
        for _ in 0..<10_000 {
            client.send([2,2,2,2,2])
        }
        
        Thread.sleep(forTimeInterval: 5)
        try client.diconnect()
        try server.stop()
    }
    
    func testWebSocketClientServer() throws {
        class ServerDelegate: WebSocketServerProtocol {
            var connections = [WebSocket]()
            var closedConnection = false
            func onConnection(requestHead: HTTPRequestHead, webSocket: WebSocket, channel: Channel) {
                connections.append(webSocket)
                webSocket.send("Hello")
                webSocket.onText { ws, text in
                    XCTAssertEqual(text, "Well hello!")
                    ws.close(promise: nil)
                    self.connections.removeAll()
                    self.closedConnection = true
                    ws.onText { _, _ in }
                }
            }
        }
        
        let serverDelegate = ServerDelegate()
        let webSocketServer = try WebSocketServer(port: 25566, numberOfThreads: 1)
        webSocketServer.delegate = serverDelegate
        try webSocketServer.start()
        
        let webSocketClient = WebSocketClient(eventLoopGroupProvider: .createNew)
        
        let webSocket = try webSocketClient.connect(scheme: "ws", host: "127.0.0.1", port: 25566)
        webSocket.onText { ws, text in
            XCTAssertEqual(text, "Hello")
            ws.send("Well hello!")
        }
        _ = webSocket.onClose.always { _ in
            XCTAssertTrue(serverDelegate.closedConnection)
        }
        Thread.sleep(forTimeInterval: 5)
        XCTAssertTrue(webSocket.isClosed)
        try webSocketClient.syncShutdown()
        try webSocketServer.stop()
    }
}
#endif
