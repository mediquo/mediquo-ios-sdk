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
            targets: ["MediQuoSDK"]),
    ],
    targets: [
        .binaryTarget(
            name: "MediQuoSDK",
            url: "https://github.com/mediquo/mediquo-ios-sdk/releases/download/26.11.8/MediQuoSDK.xcframework.zip",
            checksum: "cfb1d93ba7f89f558c38b6b0a2e3ef87e85337a0c56e82b3af37965e6b0767d8"
        )
    ]
)
