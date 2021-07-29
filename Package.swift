// swift-tools-version:5.3
import PackageDescription

var packageDependencies: [Package.Dependency] = []
var targetDependencies: [Target.Dependency] = []

#if !os(Windows) // Linux and Apple platform dependecies
packageDependencies = [
    .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),
    .package(url: "https://github.com/apple/swift-nio-ssl.git", from: "2.10.1"),
    .package(url: "https://github.com/MarSe32m/GLMSwift.git", .branch("main")),
    .package(url: "https://github.com/vapor/websocket-kit.git", from: "2.0.0"),
    .package(url: "https://github.com/apple/swift-crypto.git", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-nio-transport-services", from: "1.0.0")
]
targetDependencies = [
    .product(name: "NIO",package: "swift-nio"),
    .product(name: "NIOConcurrencyHelpers", package: "swift-nio"),
    .product(name: "NIOFoundationCompat", package: "swift-nio"),
    .product(name: "NIOSSL", package: "swift-nio-ssl"),
    .product(name: "NIOHTTP1", package: "swift-nio"),
    .product(name: "NIOWebSocket", package: "swift-nio"),
    .product(name: "WebSocketKit", package: "websocket-kit"),
    .product(name: "GLMSwift", package: "GLMSwift"),
    .product(name: "Crypto", package: "swift-crypto"),
    .product(name: "NIOTransportServices", package: "swift-nio-transport-services", condition: .when(platforms: [.iOS, .macOS, .watchOS, .tvOS])),
    "bcrypt"
]
#else // Windows dependecies
packageDependencies = [
    //.package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),
    //.package(url: "https://github.com/apple/swift-nio-ssl.git", from: "2.10.1"),
    //.package(url: "https://github.com/nicklockwood/VectorMath.git", from: "0.4.1"),
    .package(url: "https://github.com/MarSe32m/GLMSwift.git", .branch("main")),
    //.package(url: "https://github.com/vapor/websocket-kit.git", from: "2.0.0"),
    //.package(url: "https://github.com/swift-server/async-http-client.git", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-crypto.git", .branch("main"))
]
targetDependencies = [
    //.product(name: "NIO",package: "swift-nio"),
    //.product(name: "NIOConcurrencyHelpers", package: "swift-nio"),
    //.product(name: "NIOFoundationCompat", package: "swift-nio"),
    //.product(name: "NIOSSL", package: "swift-nio-ssl"),
    //.product(name: "NIOHTTP1", package: "swift-nio"),
    //.product(name: "NIOWebSocket", package: "swift-nio"),
    //.product(name: "WebSocketKit", package: "websocket-kit"),
    .product(name: "GLMSwift", package: "GLMSwift"),
    .product(name: "Crypto", package: "swift-crypto"),
    "bcrypt"
]
#endif


let package = Package(
    name: "SebbuKit",
    platforms: [
        .macOS(.v11),
        .iOS(.v13)
    ],
    products: [
        .library(name: "SebbuKit", targets: ["SebbuKit"]),
    ],
    dependencies: packageDependencies,
    targets: [
        .target(name: "SebbuKit",
                dependencies: targetDependencies,
                resources:[.process("SpriteKit/control_pad.imageset")]),
        .target(name: "bcrypt"),
        .testTarget(
            name: "SebbuKitTests",
            dependencies: ["SebbuKit"]),
    ]
)
