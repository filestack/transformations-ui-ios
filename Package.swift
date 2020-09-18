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
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "TransformationsUIShared",
                 url: "https://github.com/filestack/transformations-ui-shared-ios.git",
                 .upToNextMajor(from: "1.0.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "TransformationsUI",
            dependencies: ["TransformationsUIShared"]
        ),
        .testTarget(
            name: "TransformationsUITests",
            dependencies: ["TransformationsUIShared", "TransformationsUI"]
        ),
    ]
)
