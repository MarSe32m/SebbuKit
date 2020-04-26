// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "SebbuKit",
    platforms: [
       .macOS(.v10_15),
       .iOS(.v13),
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(name: "SebbuKit", targets: ["SebbuKit"]),
    ],
    
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", from: "2.0.0"),
        .package(url: "https://github.com/nicklockwood/VectorMath.git", from: "0.4.1"),
        .package(url: "https://github.com/vapor/websocket-kit.git", from: "2.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(name: "SebbuKit", dependencies: [
                .product(name: "NIO",package: "swift-nio"),
                .product(name: "NIOConcurrencyHelpers", package: "swift-nio"),
                .product(name: "NIOFoundationCompat", package: "swift-nio"),
                .product(name: "NIOSSL", package: "swift-nio-ssl"),
                .product(name: "WebSocketKit", package: "websocket-kit"),
                .product(name: "VectorMath", package: "VectorMath"),
        ]),
        .testTarget(
            name: "SebbuKitTests",
            dependencies: ["SebbuKit"]),
    ]
)
