// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "GapsiKit",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(name: "Domain", targets: ["Domain"]),
        .library(name: "Data", targets: ["Data"]),
    ],
    targets: [
        .target(name: "Domain"),
        .target(name: "Data", dependencies: ["Domain"]),
        .testTarget(name: "DomainTests", dependencies: ["Domain"]),
        .testTarget(
            name: "DataTests",
            dependencies: ["Data", "Domain"],
            resources: [.copy("Fixtures")]
        ),
    ]
)
