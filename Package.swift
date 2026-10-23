// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MediQuoSDK",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "MediQuoSDK",
            targets: ["MediQuoSDK", "MediQuoSDKDependencies"]),
    ],
    dependencies: [
        // Keep aligned with the version used to build MediQuoSDK in mediquo-mobile.
        .package(url: "https://github.com/Vonage/vonage-client-sdk-video-transformers.git", exact: "2.33.0"),
    ],
    targets: [
        .binaryTarget(
            name: "MediQuoSDK",
            url: "https://github.com/mediquo/mediquo-ios-sdk/releases/download/26.10.3/MediQuoSDK.xcframework.zip",
            checksum: "1840101059070b138f0ececcf06b6fe111a09cd7d30492cbb805e41f44c41223"
        ),
        // Binary targets cannot declare dependencies. This source target makes
        // SwiftPM embed the dynamic framework required by MediQuoSDK.
        .target(
            name: "MediQuoSDKDependencies",
            dependencies: [
                .product(name: "VonageClientSDKVideoTransformers", package: "vonage-client-sdk-video-transformers"),
            ]
        )
    ]
)
