import Vapor
import Framework
import Fluent
import FluentSQLiteDriver
import FluentPostgresDriver

extension Application {
    static let databaseUrl = URL(string: Environment.get("DB_URL")!)!
}

public func configure(_ app: Application) throws {

    try app.databases.use(.postgres(url: Application.databaseUrl), as: .psql)

    let modules: [ModuleInterface] = [
        UserModule()
    ]
    
    for module in modules {
        try module.boot(app)
    }
    
    for module in modules {
        try module.setUp(app)
    }
    
    try app.autoMigrate().wait()
}
