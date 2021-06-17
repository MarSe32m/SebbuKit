import XCTest
import SebbuKit
#if !os(Windows)
import NIO
#endif

let testData = (0..<128).map { _ in UInt8.random(in: .min ... .max) }

final class SebbuKitTests: XCTestCase {
    func testNetworkUtils() {
        let ipAddress = NetworkUtils.publicIP
        
        XCTAssert(ipAddress != nil, "IP Address was nil")
        XCTAssert(ipAddress!.range(of: #"\b^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$\b"#,
        options: .regularExpression) != nil, "IP Address: \(ipAddress!), regex failed!")
    }
    
    #if !os(Windows)
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
        let server = UDPServer(port: 25565)
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
            client.send(data: testData, address: try! .init(ipAddress: "127.0.0.1", port: 25565))
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
                client.eventLoopGroup.next().scheduleTask(deadline: NIODeadline.now() + .milliseconds(500)) {
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
    #endif
}
