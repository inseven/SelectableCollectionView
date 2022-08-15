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
    dependencies: [],
    targets: [
        .target(
            name: "SelectableCollectionView",
            dependencies: [],
            resources: [.process("Resources")]),
        .testTarget(
            name: "SelectableCollectionViewTests",
            dependencies: ["SelectableCollectionView"]),
    ]
)
