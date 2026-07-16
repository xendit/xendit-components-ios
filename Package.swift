// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "XenditComponents",
    defaultLocalization: "en",
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
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.0.0"),
        .package(url: "https://github.com/exyte/Macaw.git", from: "0.9.0"),
        .package(url: "https://github.com/iziz/libPhoneNumber-iOS.git", exact: "1.1.0"),
        .package(url: "https://github.com/airbnb/lottie-spm.git", from: "4.4.0")
    ],
    targets: [
        .target(
            name: "XenditComponents",
            dependencies: [
                .product(name: "Kingfisher", package: "Kingfisher"),
                .product(name: "Macaw", package: "Macaw"),
                .product(name: "libPhoneNumber", package: "libPhoneNumber-iOS"),
                .product(name: "Lottie", package: "lottie-spm")
            ],
            path: "Sources/XenditComponents",
            resources: [.process("Resources")]
        )
    ]
)
