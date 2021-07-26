// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "stripe-kit",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "StripeKit", targets: ["StripeKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/slashmo/async-http-client.git", .branch("feature/tracing")),
        .package(url: "https://github.com/apple/swift-crypto.git", from: "1.0.0")
    ],
    targets: [
        .target(name: "StripeKit", dependencies: [
            .product(name: "AsyncHTTPClient", package: "async-http-client"),
            .product(name: "Crypto", package: "swift-crypto"),
        ]),
        .testTarget(name: "StripeKitTests", dependencies: [
            .target(name: "StripeKit")
        ])
    ]
)
