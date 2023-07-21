// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "SebbuKit",
    platforms: [
        .macOS(.v12),
        .iOS(.v15)
    ],
    products: [
        .library(name: "SebbuKit", targets: ["SebbuKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", .branch("main")),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", .branch("main")),
        .package(url: "https://github.com/apple/swift-collections.git", .branch("main")),
        .package(url: "https://github.com/apple/swift-nio-transport-services", .branch("main")),
        
        .package(url: "https://github.com/MarSe32m/GLMSwift.git", .branch("main")),
        .package(url: "https://github.com/MarSe32m/sebbu-bitstream.git", .branch("main")),
        .package(url: "https://github.com/MarSe32m/sebbu-ts-ds.git", .branch("main")),
        .package(url: "https://github.com/MarSe32m/sebbu-networking.git", .branch("main")),
        .package(url: "https://github.com/MarSe32m/sebbu-concurrency.git", .branch("main")),
        .package(url: "https://github.com/MarSe32m/sebbu-cryptography.git", .branch("main")),
        
        .package(url: "https://github.com/vapor/websocket-kit.git", .branch("main"))
    ],
    targets: [
        .target(name: "SebbuKit",
                dependencies: [
                    .product(name: "NIO",package: "swift-nio", condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .linux])),
                    .product(name: "NIOConcurrencyHelpers", package: "swift-nio", condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .linux])),
                    .product(name: "NIOFoundationCompat", package: "swift-nio", condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .linux])),
                    .product(name: "NIOSSL", package: "swift-nio-ssl", condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .linux])),
                    .product(name: "NIOHTTP1", package: "swift-nio", condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .linux])),
                    .product(name: "NIOWebSocket", package: "swift-nio", condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .linux])),
                    .product(name: "WebSocketKit", package: "websocket-kit", condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .linux])),
                    .product(name: "NIOTransportServices", package: "swift-nio-transport-services", condition: .when(platforms: [.iOS, .macOS, .watchOS, .tvOS])),
                    .product(name: "GLMSwift", package: "GLMSwift"),
                    .product(name: "SebbuBitStream", package: "sebbu-bitstream"),
                    .product(name: "SebbuCrypto", package: "sebbu-cryptography"),
                    .product(name: "SebbuTSDS", package: "sebbu-ts-ds"),
                    .product(name: "SebbuNetworking", package: "sebbu-networking"),
                    .product(name: "SebbuConcurrency", package: "sebbu-concurrency"),
                    .product(name: "DequeModule", package: "swift-collections")
                ],
                resources:[.process("SpriteKit/control_pad.imageset")]),
        .testTarget(
            name: "SebbuKitTests",
            dependencies: ["SebbuKit"]),
    ]
)
