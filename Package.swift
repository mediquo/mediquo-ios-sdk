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
            url: "https://github.com/mediquo/mediquo-ios-sdk/releases/download/10.2.0/MediQuoSDK.xcframework.zip",
            checksum: "5fe517ed87af1c88112cfe6558c133cf2d9f1ef29627532fb9c57cf0b50e72a7"
        )
    ]
)
