// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Zenix",
    platforms: [
       .macOS(.v13)
    ],
    products: [
        .library(name: "Common", targets: ["Common"]),
        .library(name: "Entities", targets: ["Entities"]),
        .library(name: "AmeritradeService", targets: ["AmeritradeService"]),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.83.1"),
        // 🗄 An ORM for SQL and NoSQL databases.
        .package(url: "https://github.com/vapor/fluent.git", from: "4.8.0"),
        // 🪶 Fluent driver for SQLite.
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0"),
    ],
    targets: [
        .target(name: "Common"),
        .target(name: "Entities"),
        .target(name: "AmeritradeService", dependencies: ["Common", "Entities"]),
        .executableTarget(
            name: "App",
            dependencies: [
                "Common", "Entities",
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
                .product(name: "Vapor", package: "vapor"),
            ]
        ),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),

            // Workaround for https://github.com/apple/swift-package-manager/issues/6940
            .product(name: "Vapor", package: "vapor"),
            .product(name: "Fluent", package: "Fluent"),
            .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
        ])
    ]
)
