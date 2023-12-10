import Vapor

struct TradingAccountRouter: RouteCollection {
    
    let controller = TradingAccountController()
    
    func boot(routes: RoutesBuilder) throws {
        let api = routes
            .grouped("api")
            .grouped("trading")
    }
}
