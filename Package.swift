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
            url: "https://github.com/mediquo/mediquo-ios-sdk/releases/download/10.1.0/MediQuoSDK.xcframework.zip",
            checksum: "f7e27aaa41e4b02d3863eefa60a6e138444c30148c63ba9895ccc43a400a14c4"
        )
    ]
)
