@testable import App
import Entities
import Fluent
import Vapor

class TestContestRepository: ContestRepository, TestRepository {
    var contests: [ContestModel]
    
    init(contests: [ContestModel] = []) {
        self.contests = contests
    }
    
    typealias Model = ContestModel
    
    func create(_ model: ContestModel) async throws {
        model.id = UUID()
        model.$participants.value = []
        contests.append(model)
    }

    func delete(id: UUID) async throws {
        contests.removeAll(where: { $0.id == id })
    }
    
    func count() async throws -> Int {
        contests.count
    }
    
    func find(id: UUID) async throws -> ContestModel? {
        let model = contests.first(where: { $0.id == id })
        return model
    }
    
    func all() async throws -> [ContestModel] {
        contests
    }
    
    func update(_ model: ContestModel) async throws {
        let index = contests.firstIndex(where: { $0.id == model.id })!
        contests.remove(at: index)
        contests.insert(model, at: index)
    }
}
