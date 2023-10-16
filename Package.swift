// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "swiftui-niche-pieces",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "SearchableExtensions",
            targets: ["SearchableExtensions"]),
        .library(
            name: "SheetExtensions",
            targets: ["SheetExtensions"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-case-paths", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/pointfreeco/swiftui-navigation", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        .target(name: "SearchableExtensions"),
        .target(
            name: "SheetExtensions",
            dependencies: [
                .product(name: "CasePaths", package: "swift-case-paths"),
                .product(name: "SwiftUINavigation", package: "swiftui-navigation")
            ]
        )
    ]
)
