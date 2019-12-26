// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoreMLHelpers",
    platforms: [.iOS(.v11)],
    products: [
        .library(
            name: "CoreMLHelpers",
            targets: ["CoreMLHelpers"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "CoreMLHelpers",
            dependencies: [],
            path: "CoreMLHelpers"),
    ]
)
