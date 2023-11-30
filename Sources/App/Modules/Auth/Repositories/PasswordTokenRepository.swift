import Vapor
import Framework
import Fluent

protocol PasswordTokenRepository: Repository {
    func find(forUserID id: UUID) async throws -> PasswordTokenModel?
    func find(token: String) async throws -> PasswordTokenModel?
    func delete(forUserID id: UUID) async throws
}

struct DatabasePasswordTokenRepository: PasswordTokenRepository, DatabaseRepository {
    typealias Model = PasswordTokenModel
    
    var database: Database
    
    func find(forUserID id: UUID) async throws -> PasswordTokenModel? {
        try await PasswordTokenModel.query(on: database)
            .filter(\.$user.$id == id)
            .first()
     }
    
    func find(token: String) async throws -> PasswordTokenModel? {
        try await PasswordTokenModel.query(on: database)
            .filter(\.$value == token)
            .first()
    }

    func delete(forUserID id: UUID) async throws {
        try await PasswordTokenModel.query(on: database)
            .filter(\.$user.$id == id)
            .delete()
    }
}

extension Application.Repositories {
    var passwordTokens: any PasswordTokenRepository {
        guard let factory = storage.makePasswordTokenRepository else {
            fatalError("PasswordToken repository not configured, use: app.repositories.use")
        }
        return factory(app)
    }
    
    func use(_ make: @escaping (Application) -> (any PasswordTokenRepository)) {
        storage.makePasswordTokenRepository = make
    }
}
