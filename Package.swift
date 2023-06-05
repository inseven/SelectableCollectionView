// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SelectableCollectionView",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "SelectableCollectionView",
            targets: ["SelectableCollectionView"]),
    ],
    dependencies: [
        .package(url: "https://github.com/inseven/interact.git",  .upToNextMajor(from: "2.13.0"))
    ],
    targets: [
        .target(
            name: "SelectableCollectionView",
            dependencies: [
                .product(name: "Interact", package: "Interact"),
            ],
            resources: [.process("Resources")]),
        .testTarget(
            name: "SelectableCollectionViewTests",
            dependencies: ["SelectableCollectionView"]),
    ]
)
