// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MediQuoSDK",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "MediQuoSDK",
            targets: ["MediQuoSDK"]),
    ],
    targets: [
        .binaryTarget(
            name: "MediQuoSDK",
            url: "https://github.com/mediquo/mediquo-ios-sdk/releases/download/10.9.2/MediQuoSDK.xcframework.zip",
            checksum: "7c59587744ed89661c27801b76c9fc4e56fe43368c005dd03d0b44c3ea7d27b5"
        )
    ]
)
