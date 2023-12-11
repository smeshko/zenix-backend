import Entities
import Fluent
import Vapor

protocol ContestRepository: Repository {
    func create(_ model: ContestModel) async throws
    func all() async throws -> [ContestModel]
    func find(id: UUID) async throws -> ContestModel?
    func update(_ model: ContestModel) async throws
}

struct DatabaseContestRepository: ContestRepository, DatabaseRepository {
    
    typealias Model = ContestModel
    let database: Database    

    func all() async throws -> [ContestModel] {
        try await ContestModel
            .query(on: database)
            .with(\.$creator)
            .with(\.$participants)
            .all()
    }
    
    func find(id: UUID) async throws -> ContestModel? {
        try await ContestModel
            .query(on: database)
            .filter(\.$id == id)
            .with(\.$creator)
            .with(\.$participants)
            .first()
    }
    
    func create(_ model: ContestModel) async throws {
        try await model.create(on: database)
    }
    
    func update(_ model: ContestModel) async throws {
        try await model.update(on: database)
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
