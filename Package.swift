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
            url: "https://github.com/mediquo/mediquo-ios-sdk/releases/download/26.10.2/MediQuoSDK.xcframework.zip",
            checksum: "0e3a01cffa5b296ba38177b8272e4466f491a5f58b090955d23be34c48c08536"
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
