// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ESPNLiquidGlass",
    platforms: [
        .iOS(.v18)
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