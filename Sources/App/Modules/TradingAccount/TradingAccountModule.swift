import Vapor

struct TradingAccountModule: ModuleInterface {

    let router = TradingAccountRouter()

    func boot(_ app: Application) throws {
        app.migrations.add(TradingAccountMigrations.v1())
        
        try router.boot(routes: app.routes)
    }
}
