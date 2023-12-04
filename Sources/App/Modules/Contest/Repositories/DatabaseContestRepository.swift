import Entities
import Fluent
import Framework
import Vapor

protocol ContestRepository: Repository {
    func create(_ model: ContestModel) async throws
    func all() async throws -> [ContestModel]
    func find(id: UUID?) async throws -> ContestModel?

}

struct DatabaseContestRepository: ContestRepository, DatabaseRepository {
    typealias Model = ContestModel
    let database: Database
    
    func all() async throws -> [ContestModel] {
        try await ContestModel.query(on: database).all()
    }
    
    func find(id: UUID?) async throws -> ContestModel? {
        try await ContestModel.find(id, on: database)
    }
    
    func create(_ model: ContestModel) async throws {
        try await model.create(on: database)
    }
}

extension Application.Repositories {
    var contests: any ContestRepository {
        guard let storage = storage.makeContestRepository else {
            fatalError("UserRepository not configured, use: app.userRepository.use()")
        }
        
        return storage(app)
    }
    
    func use(_ make: @escaping (Application) -> (any ContestRepository)) {
        storage.makeContestRepository = make
    }
}
