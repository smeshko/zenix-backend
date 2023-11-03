import Framework
import Vapor

struct RootModule: ModuleInterface {
    
    let router = RootRouter()
    
    func boot(_ app: Application) throws {
        try router.boot(routes: app.routes)
    }
}
