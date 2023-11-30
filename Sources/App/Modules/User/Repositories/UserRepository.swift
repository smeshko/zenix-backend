import Entities
import Vapor
import Fluent
import Framework

protocol UserRepository: Repository {
    func find(email: String) async throws -> UserAccountModel?
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



