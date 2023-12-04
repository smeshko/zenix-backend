import Entities
import Fluent
import Framework
import Vapor

protocol UserRepository: Repository {
    func find(email: String) async throws -> UserAccountModel?
    func create(_ model: UserAccountModel) async throws
    func all() async throws -> [UserAccountModel]
    func find(id: UUID?) async throws -> UserAccountModel?
    func set<Field>(
        _ field: KeyPath<UserAccountModel, Field>,
        to value: Field.Value,
        for modelID: UUID
    ) async throws where Field : QueryableProperty, Field.Model == UserAccountModel
}

struct DatabaseUserRepository: UserRepository, DatabaseRepository {
    typealias Model = UserAccountModel
    
    let database: Database

    func find(email: String) async throws -> UserAccountModel? {
        try await UserAccountModel.query(on: database)
            .filter(\.$email == email)
            .first()
    }
    
    func set<Field>(
        _ field: KeyPath<UserAccountModel, Field>,
        to value: Field.Value,
        for modelID: UUID
    ) async throws where Field : QueryableProperty, Field.Model == UserAccountModel {
        try await UserAccountModel.query(on: database)
            .filter(\.$id == modelID)
            .set(field, to: value)
            .update()
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
