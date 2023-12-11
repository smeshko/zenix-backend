import Entities
import Vapor

struct TradingAccountController {
    func create(_ req: Request) async throws -> TradingAccount.Create.Response {
        let user = try req.auth.require(UserAccountModel.self)
        let request = try req.content.decode(TradingAccount.Create.Request.self)
        
        let account = try TradingAccountModel(from: request, user: user)
        
        return .init(from: account)
    }
}
