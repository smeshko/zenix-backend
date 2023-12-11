import Vapor
import Fluent

final class TradingAccountModel: DatabaseModelInterface {
    typealias Module = TradingAccountModule
    static var schema: String { "trading_accounts" }
    
    @ID()
    var id: UUID?
    
    @Enum(key: FieldKeys.v1.provider)
    var provider: Provider
    
    @Parent(key: FieldKeys.v1.userId)
    var user: UserAccountModel

    init() {}
    
    init(
        id: UUID? = nil,
        user: UserAccountModel,
        provider: Provider = .etrade
    ) throws {
        self.id = id
        self.$user.id = try user.requireID()
        self.provider = provider
    }
}

extension TradingAccountModel {
    enum Provider: String, Codable {
        case etrade, webull
        
        static var schema: String {
            "provider_enum"
        }
    }
}

extension TradingAccountModel {
    struct FieldKeys {
        struct v1 {
            static var provider: FieldKey { "provider" }
            static var userId: FieldKey { "user_id" }
            static var pivotId: FieldKey { "pivot_id" }
        }
    }
}
