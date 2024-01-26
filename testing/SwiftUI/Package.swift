// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUI",
    platforms: [ .iOS(.v15), .macOS(.v11) ],
    products: [
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/getditto/DittoSwiftPackage", branch: "main"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .testTarget(
            name: "SwiftUITests",
            dependencies: [
                .product(name: "DittoSwift", package: "DittoSwiftPackage")
            ]
        )
    ]
)
