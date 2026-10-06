// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "GapsiKit",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(name: "Domain", targets: ["Domain"]),
        .library(name: "DataLayer", targets: ["DataLayer"]),
    ],
    targets: [
        .target(name: "Domain"),
        .target(name: "DataLayer", dependencies: ["Domain"]),
        .testTarget(name: "DomainTests", dependencies: ["Domain"]),
        .testTarget(
            name: "DataLayerTests",
            dependencies: ["DataLayer", "Domain"],
            resources: [.copy("Fixtures")]
        ),
    ]
)
