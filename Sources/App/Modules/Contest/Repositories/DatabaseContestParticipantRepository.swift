import Entities
import Fluent
import Vapor

protocol ContestParticipantsRepository: Repository {
    func attach(
        _ user: UserAccountModel,
        to contest: ContestModel
    ) async throws
    
    func attach(
        _ user: UserAccountModel,
        to contest: ContestModel,
        update: @escaping (ContestParticipantModel) throws -> ()
    ) async throws
    
    func detach(
        _ user: UserAccountModel,
        from contest: ContestModel
    ) async throws

    func contests(for account: TradingAccountModel) async throws -> [ContestParticipantModel]
    func contests(for user: UserAccountModel) async throws -> [ContestParticipantModel]
}

struct DatabaseContestParticipantsRepository: ContestParticipantsRepository, DatabaseRepository {
    typealias Model = ContestParticipantModel
    var database: Database
    
    init(database: Database) {
        self.database = database
    }
    
    func attach(_ user: UserAccountModel, to contest: ContestModel) async throws {
        try await attach(user, to: contest, update: { _ in })
    }
    
    func attach(_ user: UserAccountModel, to contest: ContestModel, update: @escaping (ContestParticipantModel) throws -> ()) async throws {
        try await user.$contests.attach(contest, on: database) { pivot in
            try update(pivot)
        }
    }
    
    func detach(_ user: UserAccountModel, from contest: ContestModel) async throws {
        try await user.$contests.detach(contest, on: database)
    }
    
    func contests(for account: TradingAccountModel) async throws -> [ContestParticipantModel] {
        try await ContestParticipantModel
            .query(on: database)
            .filter(\.$tradingAccount.$id == account.requireID())
            .with(\.$user)
            .with(\.$contest)
            .all()
    }
    
    func contests(for user: UserAccountModel) async throws -> [ContestParticipantModel] {
        try await ContestParticipantModel
            .query(on: database)
            .filter(\.$user.$id == user.requireID())
            .with(\.$contest)
            .with(\.$tradingAccount)
            .all()
    }
}

extension Application.Repositories {
    var contestParticipantss: any ContestParticipantsRepository {
        guard let storage = storage.makeContestParticipantsRepository else {
            fatalError("ContestParticipantsRepository not configured, use: app.contestParticipantsRepository.use()")
        }
        
        return storage(app)
    }
    
    func use(_ make: @escaping (Application) -> (any ContestParticipantsRepository)) {
        storage.makeContestParticipantsRepository = make
    }
}
