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
            url: "https://filebin.net/uelp9pd8x9m62gvq/MediQuoSDK.xcframework.zip",
            checksum: "4dd98edad262f2b2adbe026858df30383d7a3146ee8b88341651bad729c4a508"
        )
    ]
)
