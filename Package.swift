// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SafeInCloudSwift",
    platforms: [.macOS(.v10_15)],
    products: [
        .library(name: "SafeInCloudSwift", targets: ["SafeInCloudSwift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.4.0"),
    ],
    targets: [
        .executableTarget(name: "sic", dependencies: [
            "SafeInCloudSwift",
            .product(name: "ArgumentParser", package: "swift-argument-parser")
        ]),
        .target(name: "SafeInCloudSwift", dependencies: []),
        .testTarget(name: "SafeInCloudSwiftTests", dependencies: ["SafeInCloudSwift"]),
    ]
)
