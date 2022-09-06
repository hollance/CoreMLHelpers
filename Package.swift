// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoreMLHelpers",
    platforms: [
        .iOS(.v11),
        .macOS(.v12),
        .tvOS(.v11),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "CoreMLHelpers",
            targets: [
                "CoreMLHelpers",
            ]
        ),
    ],
    dependencies: [
        
    ],
    targets: [
        .target(
            name: "CoreMLHelpers",
            dependencies: [
                
            ]
        ),
        .target(
            name: "Experimental",
            dependencies: [
                "CoreMLHelpers"
            ]
        ),
        .testTarget(
            name: "CoreMLHelpersTests",
            dependencies: [
                "CoreMLHelpers",
            ]
        ),
    ]
)
