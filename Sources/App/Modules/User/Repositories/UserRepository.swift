import Entities
import Fluent
import Vapor

protocol UserRepository: Repository {
    func find(email: String) async throws -> UserAccountModel?
    func create(_ model: UserAccountModel) async throws
    func all() async throws -> [UserAccountModel]
    func find(id: UUID?) async throws -> UserAccountModel?
    func update(_ model: UserAccountModel) async throws
    func contests(for user: UserAccountModel) async throws -> [ContestModel]

    func attach(
        _ contest: ContestModel,
        to user: UserAccountModel,
        update: @escaping (ContestParticipantModel) -> ()
    ) async throws

    func attach(_ contest: ContestModel, to user: UserAccountModel) async throws
    func detach(_ contest: ContestModel, from user: UserAccountModel) async throws
}

struct DatabaseUserRepository: UserRepository, DatabaseRepository {
    typealias Model = UserAccountModel
    
    let database: Database

    func find(email: String) async throws -> UserAccountModel? {
        try await UserAccountModel.query(on: database)
            .filter(\.$email == email)
            .first()
    }
    
    func all() async throws -> [UserAccountModel] {
        try await UserAccountModel.query(on: database).all()
    }
    
    func find(id: UUID?) async throws -> UserAccountModel? {
        try await UserAccountModel.find(id, on: database)
    }
    
    func create(_ model: UserAccountModel) async throws {
        try await model.create(on: database)
    }
    
    func update(_ model: UserAccountModel) async throws {
        try await model.update(on: database)
    }
    
    func attach(
        _ contest: ContestModel,
        to user: UserAccountModel,
        update: @escaping (ContestParticipantModel) -> ()
    ) async throws {
        try await user.$contests.attach(contest, on: database) { pivot in
            update(pivot)
        }
    }
    
    func attach(_ contest: ContestModel, to user: UserAccountModel) async throws {
        try await attach(contest, to: user, update: { _ in })
    }
    
    func detach(_ contest: ContestModel, from user: UserAccountModel) async throws {
        try await user.$contests.detach(contest, on: database)
    }
    
    func contests(for user: UserAccountModel) async throws -> [ContestModel] {
        try await user.$contests.get(on: database)
    }
}

extension Application.Repositories {
    var users: any UserRepository {
        guard let storage = storage.makeUserRepository else {
            fatalError("UserRepository not configured, use: app.userRepository.use()")
        }
        
        return storage(app)
    }
    
    func use(_ make: @escaping (Application) -> (any UserRepository)) {
        storage.makeUserRepository = make
    }
}
