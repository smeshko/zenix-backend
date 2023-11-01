import Vapor
import Fluent
import FluentSQLiteDriver

public func configure(_ app: Application) throws {

    app.routes.defaultMaxBodySize = "10mb"
    
    switch app.environment {
    case .development, .testing:
        app.databases.use(.sqlite(.memory), as: .sqlite)
    default:
        app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
    }
    
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
