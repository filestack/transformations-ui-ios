// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TransformationsUI",
    platforms: [.iOS(.v11)],
    products: [
        .library(
            name: "TransformationsUI",
            targets: ["TransformationsUI"]
        )
    ],
    dependencies: [
        .package(name: "Filestack", url: "https://github.com/filestack/filestack-ios", .upToNextMajor(from: Version(2, 8, 0))),
        .package(name: "FilestackSDK", url: "https://github.com/filestack/filestack-swift", .upToNextMajor(from: Version(2, 8, 0))),
        .package(name: "Pikko", url: "https://github.com/rnine/Pikko.git", .upToNextMajor(from: Version(1, 1, 0))),
        .package(name: "UberSegmentedControl", url: "https://github.com/rnine/UberSegmentedControl.git", .upToNextMajor(from: Version(1, 3, 5))),
        .package(name: "SnapKit", url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: Version(5, 0, 0))),
        .package(name: "SwiftMessages", url: "https://github.com/SwiftKickMobile/SwiftMessages.git", .upToNextMajor(from: Version(9, 0, 0)))
    ],
    targets: [
        .target(
            name: "TransformationsUI",
            dependencies: ["Filestack", "FilestackSDK", "Pikko", "UberSegmentedControl", "SnapKit", "SwiftMessages", "TUIKit"],
            resources: [
                .copy("VERSION"),
                .copy("Resources/Fonts/Montserrat-Regular.ttf"),
                .copy("Resources/Fonts/Montserrat-SemiBold.ttf"),
                .copy("Resources/Fonts/Montserrat-Bold.ttf"),
                .copy("Resources/CoreImage/RandomNoise.cikernel")
            ]
        ),
        .target(name: "TUIKit")
    ]
)
