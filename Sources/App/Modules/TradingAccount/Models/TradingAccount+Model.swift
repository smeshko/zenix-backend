import Entities
import Vapor

extension TradingAccount.Create.Response: Content {
    init(from model: TradingAccountModel) {
        self.init()
    }
}

extension TradingAccountModel {
    convenience init(
        from request: TradingAccount.Create.Request,
        user: UserAccountModel
    ) throws {
        try self.init(
            user: user,
            provider: request.provider.db
        )
    }
}

extension TradingAccount.Create.Provider {
    var db: TradingAccountModel.Provider {
        switch self {
        case .etrade: .etrade
        case .webull: .webull
        }
    }
}
