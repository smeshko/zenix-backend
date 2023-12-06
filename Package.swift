// swift-tools-version:5.9
import PackageDescription

let fluent = Target.Dependency.product(name: "Fluent", package: "fluent")
let vapor = Target.Dependency.product(name: "Vapor", package: "vapor")
let prometheus = Target.Dependency.product(name: "SwiftPrometheus", package: "SwiftPrometheus")
let entities = Target.Dependency.product(name: "Entities", package: "zenix-entities")
let common = Target.Dependency.product(name: "Common", package: "zenix-common")

let package = Package(
    name: "Zenix",
    platforms: [
        .macOS(.v13)
    ],
    products: [
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.83.1"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.8.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),
        .package(url: "https://github.com/MrLotU/SwiftPrometheus.git", from: "1.0.2"),
        .package(url: "https://github.com/vapor/jwt.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/queues.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/queues-redis-driver.git", from: "1.0.0"),
        .package(url: "https://github.com/binarybirds/swift-html", from: "1.7.0"),
        .package(url: "https://github.com/smeshko/zenix-entities", from: "0.1.0"),
        .package(url: "https://github.com/smeshko/zenix-common", from: "0.1.0"),
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                common, entities, vapor, fluent, prometheus,
                .product(name: "QueuesRedisDriver", package: "queues-redis-driver"),
                .product(name: "SwiftHtml", package: "swift-html"),
                .product(name: "SwiftSvg", package: "swift-html"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "JWT", package: "jwt"),
            ]
        ),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
            .product(name: "XCTQueues", package: "queues"),

            // Workaround for https://github.com/apple/swift-package-manager/issues/6940
            .product(name: "Vapor", package: "vapor"),
            .product(name: "Fluent", package: "Fluent"),
            .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
        ])
    ]
)
