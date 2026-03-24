// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "digia_expr_swift",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "DigiaExpr",
            targets: ["DigiaExpr"]
        ),
    ],
    targets: [
        .target(
            name: "DigiaExpr"
        ),
        .testTarget(
            name: "DigiaExprTests",
            dependencies: ["DigiaExpr"]
        ),
    ]
)
