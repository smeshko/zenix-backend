import Vapor
import Framework
import Fluent
import FluentSQLiteDriver
import FluentPostgresDriver
import Prometheus
import Metrics

public func configure(_ app: Application) throws {

    if let databaseURL = Environment.get("DATABASE_URL") {
        try app.databases.use(.postgres(url: databaseURL), as: .psql)
    } else {
        app.logger.error("DATABASE_URL empty")
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
