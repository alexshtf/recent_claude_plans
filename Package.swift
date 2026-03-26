// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ClaudePlansMenu",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "ClaudePlansMenu",
            path: "Sources/ClaudePlansMenu",
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency=minimal")]
        )
    ]
)
