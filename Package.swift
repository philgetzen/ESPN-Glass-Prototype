// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ESPNLiquidGlass",
    platforms: [
        .iOS("26.0")  // Using iOS 26.0 for Liquid Glass APIs
    ],
    products: [
        .library(
            name: "ESPNLiquidGlass",
            targets: ["ESPNLiquidGlass"]),
    ],
    targets: [
        .target(
            name: "ESPNLiquidGlass",
            path: "ESPNLiquidGlass",
            resources: [
                .process("Resources")
            ]
        )
    ]
)