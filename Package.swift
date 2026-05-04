// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "XenditComponents",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "XenditComponents",
            targets: ["XenditComponents"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/CocoaLumberjack/CocoaLumberjack.git", from: "3.7.0"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.0.0"),
        .package(url: "https://github.com/SVGKit/SVGKit.git", exact: "3.0.0"),
        .package(url: "https://github.com/iziz/libPhoneNumber-iOS.git", exact: "1.1.0")
    ],
    targets: [
        .target(
            name: "XenditComponents",
            dependencies: [
                .product(name: "CocoaLumberjackSwift", package: "CocoaLumberjack"),
                .product(name: "Kingfisher", package: "Kingfisher"),
                .product(name: "SVGKit", package: "SVGKit"),
                .product(name: "libPhoneNumber", package: "libPhoneNumber-iOS")
            ],
            path: "Sources/XenditComponents",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "XenditComponentsTests",
            dependencies: ["XenditComponents"],
            path: "Tests/XenditComponentsTests"
        )
    ]
)
