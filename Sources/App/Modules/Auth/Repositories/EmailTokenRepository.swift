import Framework
import Foundation
import Vapor
import Fluent

protocol EmailTokenRepository: Repository {
    func find(forUserID id: UUID) async throws -> EmailTokenModel?
    func find(token: String) async throws -> EmailTokenModel?
    func delete(forUserID id: UUID) async throws
}

struct DatabaseEmailTokenRepository: EmailTokenRepository, DatabaseRepository {
    typealias Model = EmailTokenModel
    
    let database: Database
    
    func find(forUserID id: UUID) async throws -> EmailTokenModel? {
        try await EmailTokenModel.query(on: database)
            .filter(\.$user.$id == id)
            .first()
    }
    
    func find(token: String) async throws -> EmailTokenModel? {
        try await EmailTokenModel.query(on: database)
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
    var emailTokens: any EmailTokenRepository {
        guard let factory = storage.makeEmailTokenRepository else {
            fatalError("EmailToken repository not configured, use: app.repositories.use")
        }
        return factory(app)
    }
    
    func use(_ make: @escaping (Application) -> (any EmailTokenRepository)) {
        storage.makeEmailTokenRepository = make
    }
}
