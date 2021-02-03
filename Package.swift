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
        .library(
            name: "TransformationsUIShared",
            targets: ["TransformationsUIShared"]
        ),
        .library(
            name: "TransformationsUIPremiumAddOns",
            targets: ["TransformationsUIPremiumAddOns"]
        ),
        .library(
            name: "FilestackSDK",
            targets: ["FilestackSDK"]
        ),
        .library(
            name: "ObjcDefs",
            targets: ["ObjcDefs"]
        ),
        .library(
            name: "Filestack",
            targets: ["Filestack"]
        ),
        .library(
            name: "UberSegmentedControl",
            targets: ["UberSegmentedControl"]
        ),
        .library(
            name: "Pikko",
            targets: ["Pikko"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "TransformationsUI",
            dependencies: ["TransformationsUIShared"]
        ),
        .binaryTarget(
            name: "TransformationsUIShared",
            path: "artifacts/TransformationsUIShared.xcframework"
        ),
        .binaryTarget(
            name: "TransformationsUIPremiumAddOns",
            path: "artifacts/TransformationsUIPremiumAddOns.xcframework"
        ),
        .binaryTarget(
            name: "FilestackSDK",
            path: "artifacts/FilestackSDK.xcframework"
        ),
        .binaryTarget(
            name: "ObjcDefs",
            path: "artifacts/ObjcDefs.xcframework"
        ),
        .binaryTarget(
            name: "Filestack",
            path: "artifacts/Filestack.xcframework"
        ),
        .binaryTarget(
            name: "UberSegmentedControl",
            path: "artifacts/UberSegmentedControl.xcframework"
        ),
        .binaryTarget(
            name: "Pikko",
            path: "artifacts/Pikko.xcframework"
        ),
    ]
)
