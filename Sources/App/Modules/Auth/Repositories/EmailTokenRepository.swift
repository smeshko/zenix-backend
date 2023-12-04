import Framework
import Foundation
import Vapor
import Fluent

protocol EmailTokenRepository: Repository {
    func find(forUserID id: UUID) async throws -> EmailTokenModel?
    func find(token: String) async throws -> EmailTokenModel?
    func delete(forUserID id: UUID) async throws
    func create(_ model: EmailTokenModel) async throws
    func all() async throws -> [EmailTokenModel]
    func find(id: UUID?) async throws -> EmailTokenModel?

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
        try await EmailTokenModel.query(on: database)
            .filter(\.$user.$id == id)
            .delete()
    }
    
    func all() async throws -> [EmailTokenModel] {
        try await EmailTokenModel.query(on: database).all()
    }
    
    func find(id: UUID?) async throws -> EmailTokenModel? {
        try await EmailTokenModel.find(id, on: database)
    }
    
    func create(_ model: EmailTokenModel) async throws {
        try await model.create(on: database)
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
