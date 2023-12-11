@testable import App
import Entities
import Fluent
import Vapor

class TestTradingAccountRepository: TradingAccountRepository, TestRepository {
    
    var accounts: [TradingAccountModel]
    
    typealias Model = TradingAccountModel
    
    init(accounts: [TradingAccountModel] = []) {
        self.accounts = accounts
    }
    
    func create(_ model: TradingAccountModel) async throws {
        accounts.append(model)
    }
    
    func all(for user: UserAccountModel) async throws -> [TradingAccountModel] {
        accounts.filter { $0.$user.id == user.id }
    }
    
    func find(id: UUID) async throws -> TradingAccountModel? {
        accounts.first { $0.id == id }
    }
    
    func delete(id: UUID) async throws {
        accounts.removeAll { $0.id == id }
    }
    
    func count() async throws -> Int {
        accounts.count
    }
}
