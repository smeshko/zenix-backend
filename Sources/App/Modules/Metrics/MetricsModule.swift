import Framework
import Vapor

struct MetricsModule: ModuleInterface {
    let router = MetricsRouter()
    
    func boot(_ app: Application) throws {
        try router.boot(routes: app.routes)
    }
}
