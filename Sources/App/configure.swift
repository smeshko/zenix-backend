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
    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST")!,
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME")!,
        password: Environment.get("DATABASE_PASSWORD")!,
        database: Environment.get("DATABASE_NAME")!,
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)

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
