// swift-tools-version:5.2
import PackageDescription

var packageDependencies: [Package.Dependency] = [
    .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),
    .package(url: "https://github.com/apple/swift-nio-ssl.git", from: "2.0.0"),
    .package(url: "https://github.com/nicklockwood/VectorMath.git", from: "0.4.1"),
    .package(url: "https://github.com/vapor/websocket-kit.git", from: "2.0.0"),
    .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-crypto.git", from: "1.0.0")
]

var targetDependencies: [Target.Dependency] = [
.product(name: "NIO",package: "swift-nio"),
.product(name: "NIOConcurrencyHelpers", package: "swift-nio"),
.product(name: "NIOFoundationCompat", package: "swift-nio"),
.product(name: "NIOSSL", package: "swift-nio-ssl"),
.product(name: "WebSocketKit", package: "websocket-kit"),
.product(name: "VectorMath", package: "VectorMath"),
.product(name: "AsyncHTTPClient", package: "async-http-client"),
.product(name: "Crypto", package: "swift-crypto")]

let package = Package(
    name: "SebbuKit",
    platforms: [
       .macOS(.v10_15),
       .iOS(.v13)
    ],
    products: [
        .library(name: "SebbuKit", targets: ["SebbuKit"]),
    ],
    
    dependencies: packageDependencies,
    targets: [
        .target(name: "SebbuKit",
                dependencies: targetDependencies,
                swiftSettings: [.unsafeFlags(["-cross-module-optimization"],
                                             .when( configuration: .release))]),
        .testTarget(
            name: "SebbuKitTests",
            dependencies: ["SebbuKit"]),
    ]
)
