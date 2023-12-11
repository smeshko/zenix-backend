@testable import App
import Entities
import Fluent
import Vapor

class TestContestParticipantsRepository: ContestParticipantsRepository, TestRepository {
    var models: [ContestParticipantModel]
    
    typealias Model = ContestParticipantModel
    
    init(models: [ContestParticipantModel] = []) {
        self.models = models
    }
    
    func attach(_ user: UserAccountModel, to contest: ContestModel) async throws {
        try await attach(user, to: contest, update: { _ in })
    }
    
    func attach(_ user: UserAccountModel, to contest: ContestModel, update: @escaping (ContestParticipantModel) throws -> ()) async throws {
        let pivot = try ContestParticipantModel(id: UUID(), contest: contest, user: user)
        pivot.$user.value = user
        pivot.$contest.value = contest
        try update(pivot)
        models.append(pivot)
    }
    
    func detach(_ user: UserAccountModel, from contest: ContestModel) async throws {
        models.removeAll { $0.user.id == user.id && $0.contest.id == contest.id }
    }
    
    func contests(for account: TradingAccountModel) async throws -> [ContestParticipantModel] {
        models.filter { $0.tradingAccount?.id == account.id }
    }
    
    func contests(for user: UserAccountModel) async throws -> [ContestParticipantModel] {
        models.filter { $0.user.id == user.id }
    }
    
    func delete(id: UUID) async throws {
        models.removeAll { $0.id == id }
    }
    
    func count() async throws -> Int {
        models.count
    }
}
