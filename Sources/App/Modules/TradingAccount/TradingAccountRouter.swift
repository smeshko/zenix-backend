import Vapor

struct TradingAccountRouter: RouteCollection {
    
    let controller = TradingController()
    
    func boot(routes: RoutesBuilder) throws {
        let api = routes
            .grouped("api")
            .grouped("trading")
            .grouped(UserPayloadAuthenticator())
        
        api.post("create-account", use: controller.createTradingAccount)
    }
}
