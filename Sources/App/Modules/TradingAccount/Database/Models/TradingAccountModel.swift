import Vapor
import Fluent

final class TradingAccountModel: DatabaseModelInterface {
    typealias Module = TradingAccountModule
    static var schema: String { "trading_accounts" }
    
    @ID()
    var id: UUID?
    
    init() {}
    
    init(
        id: UUID? = nil
    ) {
        self.id = id
    }
}

extension TradingAccountModel {
    struct FieldKeys {
        struct v1 {
            
        }
    }
}
