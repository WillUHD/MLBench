// swift-tools-version: 5.9
// MLBench, a project by WillUHD, 2025. 

import PackageDescription

let package = Package(
    name: "MLBench",
    platforms: [
        .macOS("13.3")
    ],
    products: [],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "MLBench",
            dependencies: [],
            resources: [
                .copy("Resources") 
            ]
        )
    ]
)