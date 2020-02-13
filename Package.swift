// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SebbuKit",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "SebbuKit",
            targets: ["SebbuKit"]),
    ],
    dependencies: [
    .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),
    .package(url: "https://github.com/apple/swift-nio-ssl.git", from: "2.0.0"),
    .package(url: "https://github.com/nicklockwood/VectorMath.git", from: "0.4.1"),
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        // .package(url: "package url", .branch("master"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "SebbuKit",
            dependencies: ["NIO", "NIOHTTP1", "NIOWebSocket", "NIOSSL", "VectorMath"]),
        .testTarget(
            name: "SebbuKitTests",
            dependencies: ["SebbuKit"]),
    ]
)
