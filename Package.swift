// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TransformationsUI",
    platforms: [.iOS(.v11)],
    products: [
        .library(
            name: "TransformationsUI",
            type: .dynamic,
            targets: ["TransformationsUI"]
        ),
    ],
    dependencies: [
        .package(name: "Filestack", url: "https://github.com/filestack/filestack-ios", .upToNextMajor(from: Version(2, 7, 1))),
        .package(name: "FilestackSDK", url: "https://github.com/filestack/filestack-swift", .upToNextMajor(from: Version(2, 7, 0))),
        .package(name: "Pikko", url: "https://github.com/rnine/Pikko.git", .upToNextMajor(from: Version(1, 0, 9))),
        .package(name: "UberSegmentedControl", url: "https://github.com/rnine/UberSegmentedControl.git", .upToNextMajor(from: Version(1, 3, 4))),
    ],
    targets: [
        .target(
            name: "TransformationsUI",
            dependencies: ["Filestack", "FilestackSDK", "Pikko", "UberSegmentedControl"]
        ),
    ]
)
