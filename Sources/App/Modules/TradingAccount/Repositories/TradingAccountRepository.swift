import Fluent
import Vapor

protocol TradingAccountRepository: Repository {
    func create(_ model: TradingAccountModel) async throws
    func all(for user: UserAccountModel) async throws -> [TradingAccountModel]
    func find(id: UUID) async throws -> TradingAccountModel?
}

struct DatabaseTradingAccountRepository: TradingAccountRepository, DatabaseRepository {
    var database: Database
    
    init(database: Database) {
        self.database = database
    }
    
    typealias Model = TradingAccountModel
    
    func create(_ model: TradingAccountModel) async throws {
        try await model.create(on: database)
    }
    
    func all(for user: UserAccountModel) async throws -> [TradingAccountModel] {
        try await TradingAccountModel
            .query(on: database)
            .filter(\.$user.$id == user.requireID())
            .all()
    }
    
    func find(id: UUID) async throws -> TradingAccountModel? {
        try await TradingAccountModel
            .query(on: database)
            .filter(\.$id == id)
            .with(\.$user)
            .first()
    }
}

extension Application.Repositories {
    var tradingAccounts: any TradingAccountRepository {
        guard let storage = storage.makeTradingAccountsRepository else {
            fatalError("TradingAccountRepository not configured, use: app.tradingAccountRepository.use()")
        }
        
        return storage(app)
    }
    
    func use(_ make: @escaping (Application) -> (any TradingAccountRepository)) {
        storage.makeTradingAccountsRepository = make
    }
}
