import Vapor

struct RootRouter: RouteCollection {
    
    let controller = RootController()
    
    func boot(routes: RoutesBuilder) throws {
        routes.get("", use: controller.routes)
    }
}
