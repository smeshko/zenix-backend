import Vapor

struct ContestModule: ModuleInterface {
    
    let router = ContestRouter()
    
    func boot(_ app: Application) throws {
        app.migrations.add(ContestMigrations.v1())
        app.migrations.add(ContestMigrations.v2())
        
        try router.boot(routes: app.routes)
    }
}
