// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MediQuoSDK",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "MediQuoSDK",
            targets: ["MediQuoSDK"]),
    ],
    targets: [
        .binaryTarget(
            name: "MediQuoSDK",
            url: "https://github.com/mediquo/mediquo-ios-sdk/releases/download/10.7.4/MediQuoSDK.xcframework.zip",
            checksum: "7fe9903dd24680d8dfcda04f758e18e2a1bc27b4fec3c5f4c6c5465a2bdf824b"
        )
    ]
)
