import Vapor
import Fluent
import Framework
import Entities

protocol RefreshTokenRepository: Repository {
    func find(forUserID id: UUID) async throws -> RefreshTokenModel?
    func find(token: String) async throws -> RefreshTokenModel?
    func delete(forUserID id: UUID) async throws
}

struct DatabaseRefreshTokenRepository: RefreshTokenRepository, DatabaseRepository {
    typealias Model = RefreshTokenModel
    let database: Database
    
    func find(forUserID id: UUID) async throws -> RefreshTokenModel? {
        try await RefreshTokenModel.query(on: database)
            .filter(\.$user.$id == id)
            .first()
    }

    func find(token: String) async throws -> RefreshTokenModel? {
        try await RefreshTokenModel.query(on: database)
            .filter(\.$value == token)
            .first()
    }
    
    func delete(forUserID id: UUID) async throws {
        try await RefreshTokenModel.query(on: database)
            .filter(\.$user.$id == id)
            .delete()
    }
}

extension Application.Repositories {
    var refreshTokens: any RefreshTokenRepository {
        guard let factory = storage.makeRefreshTokenRepository else {
            fatalError("RefreshToken repository not configured, use: app.repositories.use")
        }
        return factory(app)
    }
    
    func use(_ make: @escaping (Application) -> (any RefreshTokenRepository)) {
        storage.makeRefreshTokenRepository = make
    }
}
