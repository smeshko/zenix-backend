@testable import App
import Entities
import Framework
import Vapor
import Crypto

class TestRefreshTokenRepository: RefreshTokenRepository, TestRepository {
    var tokens: [RefreshTokenModel]
    typealias Model = RefreshTokenModel

    init(tokens: [RefreshTokenModel] = []) {
        self.tokens = tokens
    }
    
    func find(token: String) async throws -> RefreshTokenModel? {
        tokens.first(where: { $0.value == token })
    }
    
    func find(forUserID id: UUID) async throws -> App.RefreshTokenModel? {
        tokens.first(where: { $0.$user.id == id })
    }
    
    func delete(forUserID id: UUID) async throws {
        tokens.removeAll(where: { $0.$user.id == id })
    }
    
    func create(_ model: some DatabaseModelInterface) async throws {
        model.id = UUID()
        tokens.append(model as! RefreshTokenModel)
    }
    
    func all() async throws -> [any DatabaseModelInterface] {
        tokens
    }
    
    func find(id: UUID?) async throws -> (any DatabaseModelInterface)? {
        tokens.first(where: { $0.id == id })
    }
    
    func delete(id: UUID) async throws {
        tokens.removeAll(where: { $0.id == id })
    }
    
    func count() async throws -> Int {
        tokens.count
    }
}
