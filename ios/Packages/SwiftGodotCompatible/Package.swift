// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SwiftGodot",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(name: "SwiftGodot", targets: ["SwiftGodot"]),
        .library(name: "SwiftGodotRuntime", targets: ["SwiftGodotRuntime"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax", from: "600.0.1"),
    ],
    targets: [
        .target(
            name: "ExtensionApi",
            exclude: ["ExtensionApiJson.swift", "extension_api.json"],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .executableTarget(
            name: "Generator",
            dependencies: [
                "ExtensionApi",
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
            ],
            path: "Generator",
            exclude: ["README.md"],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .plugin(
            name: "CodeGeneratorPlugin",
            capability: .buildTool(),
            dependencies: ["Generator"]
        ),
        .target(
            name: "GDExtension",
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .target(
            name: "SwiftGodotRuntime",
            dependencies: ["GDExtension"],
            swiftSettings: [
                .define("CUSTOM_BUILTIN_IMPLEMENTATIONS"),
                .unsafeFlags([
                    "-suppress-warnings",
                    "-Xfrontend", "-conditional-runtime-records",
                    "-Xfrontend", "-internalize-at-link",
                    "-Xfrontend", "-lto=llvm-full",
                ]),
                .swiftLanguageMode(.v5),
            ],
            plugins: ["CodeGeneratorPlugin"]
        ),
        .target(
            name: "SwiftGodot",
            dependencies: ["GDExtension", "SwiftGodotRuntime"],
            swiftSettings: [
                .swiftLanguageMode(.v5),
                .define("CUSTOM_BUILTIN_IMPLEMENTATIONS"),
                .unsafeFlags(["-suppress-warnings"]),
            ],
            plugins: ["CodeGeneratorPlugin"]
        ),
    ]
)
