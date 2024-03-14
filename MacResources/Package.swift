// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MacResources",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "SelectableCollectionViewMacResources",
            targets: ["SelectableCollectionViewMacResources"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "SelectableCollectionViewMacResources",
            resources: [.process("Resources")]
        ),
    ]
)
