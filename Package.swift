// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Netfox",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "Netfox",
            targets: ["Netfox"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Netfox"
        )
    ]
)
