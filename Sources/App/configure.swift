import Vapor
import Framework
import Fluent
import FluentSQLiteDriver
import FluentPostgresDriver
import Prometheus
import Metrics

extension Application {
//    static let databaseUrl = URL(string: Environment.get("DB_URL")!)!
}

public func configure(_ app: Application) throws {

//    try app.databases.use(.postgres(url: Application.databaseUrl), as: .psql)
    if let databaseURL = Environment.get("DATABASE_URL") {
        try app.databases.use(.postgres(url: databaseURL), as: .psql)
    } else {
        app.logger.error("DATABASE_URL empty")
        // Handle missing DATABASE_URL here...
        //
        // Alternatively, you could also set a different config
        // depending on wether app.environment is set to to
        // `.development` or `.production`
    }

    let promClient = PrometheusMetricsFactory(client: PrometheusClient())
    MetricsSystem.bootstrap(promClient)

    let modules: [ModuleInterface] = [
        UserModule(),
        MetricsModule()
    ]
    
    for module in modules {
        try module.boot(app)
    }
    
    for module in modules {
        try module.setUp(app)
    }
    
    try app.autoMigrate().wait()
}
