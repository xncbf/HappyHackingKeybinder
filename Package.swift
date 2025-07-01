// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "HappyHackingKeybinder",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .executable(name: "HappyHackingKeybinder", targets: ["HappyHackingKeybinder"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "HappyHackingKeybinder",
            dependencies: [],
            path: "HappyHackingKeybinder/Sources"
        )
    ]
)