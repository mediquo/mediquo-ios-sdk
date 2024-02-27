// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "mediquo-ios-sdk",
    products: [
        .library(
            name: "mediquo-ios-sdk",
            targets: ["MediQuoSDK"]),
    ],
    targets: [
        .binaryTarget(
            name: "MediQuoSDK",
            url: "https://github.com/mediquo/mediquo-ios-sdk/releases/download/10.0.4-beta1/MediQuoSDK.xcframework.zip",
            checksum: "6311f70bc4988a51289c1b61b9b41b37e7f5d332d217b022eb68e96c0250c364"
        )
    ]
)
