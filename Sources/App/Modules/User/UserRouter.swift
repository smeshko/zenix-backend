import Vapor

struct UserRouter: RouteCollection {
    
    let userController = UserController()
    
    func boot(routes: RoutesBuilder) throws {
        let api = routes
            .grouped("api")
            .grouped("user")
        
        api
            .grouped(UserCredentialsAuthenticator())
            .post("sign-in", use: userController.signIn)
        
        api.post("sign-up", use: userController.signUp)
        
        api
            .grouped(UserTokenAuthenticator())
            .post("logout", use: userController.logout)
        
        api
            .grouped(UserTokenAuthenticator())
            .delete("delete", use: userController.delete)
        
        api
            .grouped(UserTokenAuthenticator())
            .get("list", use: userController.list)
    }
}
