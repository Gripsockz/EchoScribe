// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "EchoScribe",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "EchoScribe",
            targets: ["EchoScribe"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "EchoScribe",
            dependencies: [],
            path: "EchoScribe",
            sources: [
                "App",
                "Core/Audio",
                "Core/AI", 
                "Core/Database",
                "Core/Export",
                "UI/Views",
                "UI/Components",
                "UI/Styles",
                "UI/Extensions",
                "Models",
                "Utils"
            ],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
