// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "SwiftGodotKit",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "SwiftGodotKit",
            targets: ["SwiftGodotKit"]
        ),
    ],
    dependencies: [
        .package(path: "../SwiftGodotCompatible"),
    ],
    targets: [
        .target(
            name: "SwiftGodotKit",
            dependencies: [
                .product(name: "SwiftGodot", package: "SwiftGodotCompatible"),
                "ios_libgodot",
                "libgodot",
                "apple_plugin_stubs",
            ],
            exclude: ["GodotHostBridge.swift"],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .target(
            name: "apple_plugin_stubs",
            path: "Sources/apple_plugin_stubs",
            publicHeadersPath: "include"
        ),
        .binaryTarget(
            name: "ios_libgodot",
            url: "https://github.com/migueldeicaza/godot/releases/download/v4.6.4/libgodot-ios.xcframework.zip",
            checksum: "c7b945aae1e02eabafa6578930e1ab3ac17cd1f8665ad3af4482447646d200c1"
        ),
        .systemLibrary(
            name: "libgodot"
        ),
    ]
)
