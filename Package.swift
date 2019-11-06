// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CKBVanityAddress",
    products: [
        .executable(name: "cva", targets: ["CLI"]),
        .library(name: "VanityAddress", targets: ["VanityAddress"])
    ],
    dependencies: [
        .package(url: "https://github.com/nervosnetwork/ckb-sdk-swift", from: "0.24.0")
    ],
    targets: [
        .target(
            name: "CLI",
            dependencies: ["VanityAddress"]
        ),
        .target(
            name: "VanityAddress",
            dependencies: [
                "CKB"
            ]
        )
    ]
)
