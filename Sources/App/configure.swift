import Vapor
import Framework
import Fluent
import FluentPostgresDriver

extension Environment {
    static var staging: Environment {
        .custom(name: "staging")
    }
}

public func configure(_ app: Application) throws {

    if let databaseURL = Environment.get("DATABASE_URL") {
        try app.databases.use(.postgres(url: databaseURL), as: .psql)
    } else {
        app.logger.error("DATABASE_URL empty")
    }

    app.logger.info("Environment: \((try? Environment.detect().name) ?? "env not detected")")

    let modules: [ModuleInterface] = [
        RootModule(),
        MetricsModule(),
        UserModule(),
        ContestModule()
    ]
    
    for module in modules {
        try module.boot(app)
    }
    
    for module in modules {
        try module.setUp(app)
    }
    
    try app.autoMigrate().wait()
}
