// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "GapsiKit",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(name: "Domain", targets: ["Domain"]),
    ],
    targets: [
        .target(name: "Domain"),
        .testTarget(name: "DomainTests", dependencies: ["Domain"]),
    ]
)
