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
            url: "https://github.com/mediquo/mediquo-ios-sdk/releases/download/10.1.2/MediQuoSDK.xcframework.zip",
            checksum: "404e42cf0c57df243384260d910057f5dc21ce3b154f46af5be873f7205e360b"
        )
    ]
)
