import Vapor

struct UserRouter: RouteCollection {
    
    let controller = UserController()
    
    func boot(routes: RoutesBuilder) throws {
        let api = routes
            .grouped("api")
            .grouped("user")
                
        api
            .grouped(UserPayloadAuthenticator())
            .delete("delete", use: controller.delete)
        
        api
            .grouped(UserPayloadAuthenticator())
            .get("me", use: controller.getCurrentUser)

        api
            .grouped(UserPayloadAuthenticator())
            .grouped(EnsureAdminUserMiddleware())
            .get("list", use: controller.list)
    }
}
