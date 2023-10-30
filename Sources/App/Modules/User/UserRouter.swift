import Vapor

struct UserRouter: RouteCollection {
    
    let apiController = UserApiController()
    
    func boot(routes: RoutesBuilder) throws {
        let api = routes
            .grouped("api")
            .grouped("user")
        
        api
            .grouped(UserCredentialsAuthenticator())
            .post("sign-in", use: apiController.signIn)
        
        api
            .post("sign-up", use: apiController.signUp)
    }
}
