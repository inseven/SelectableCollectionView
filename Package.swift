// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SelectableCollectionView",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "SelectableCollectionView",
            targets: ["SelectableCollectionView"]),
    ],
    dependencies: [
        .package(path: "MacResources"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        .package(url: "https://github.com/inseven/licensable.git", .upToNextMajor(from: "0.0.1")),
        .package(url: "https://github.com/tribalworldwidelondon/CassowarySwift.git", from: "2.0.0"),
    ],
    targets: [
        .target(
            name: "SelectableCollectionView",
            dependencies: [
                .product(name: "Cassowary", package: "CassowarySwift"),
                .product(name: "Licensable", package: "Licensable"),
                .product(name: "SelectableCollectionViewMacResources",
                         package: "MacResources",
                         condition: .when(platforms: [.macOS])),
            ],
            resources: [.process("Resources")]),
        .testTarget(
            name: "SelectableCollectionViewTests",
            dependencies: ["SelectableCollectionView"]),
    ]
)
