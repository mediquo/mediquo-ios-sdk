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
            url: "https://github.com/mediquo/mediquo-ios-sdk/releases/download/10.0.5/MediQuoSDK.xcframework.zip",
            checksum: "d97de43e7e25e2eccdcdea912b85e19efb0afa22107f42c5ffed06ac06e93e43"
        )
    ]
)
