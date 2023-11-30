import Vapor
import Fluent
import Entities

public protocol RequestService {
    func `for`(_ req: Request) -> Self
}

public protocol Repository: RequestService {
    associatedtype Model: DatabaseModelInterface
    
    func create(_ model: some DatabaseModelInterface) async throws
    func all() async throws -> [any DatabaseModelInterface]
    func find(id: UUID?) async throws -> (any DatabaseModelInterface)?
    func delete(id: UUID) async throws
    func count() async throws -> Int
}

public protocol TokenRepository: Repository {
    func find(forUserID id: UUID) async throws -> (any TokenDatabaseModel)?
    func find(token: String) async throws -> (any TokenDatabaseModel)?
    func delete(forUserID id: UUID) async throws
}

public extension Repository where Self: DatabaseRepository {
    func all() async throws -> [any DatabaseModelInterface] {
        try await Model.query(on: database).all()
    }
    
    func find(id: UUID?) async throws -> (any DatabaseModelInterface)?{
        try await Model.find(id, on: database)
    }
    
    func delete(id: UUID) async throws {
        try await Model.find(id, on: database)?
            .delete(on: database)
    }
    
    func count() async throws -> Int {
        try await Model.query(on: database).count()
    }
    
    func create(_ model: some DatabaseModelInterface) async throws {
        try await model.create(on: database)
    }
}

public extension TokenRepository where Self: DatabaseRepository, Model: TokenDatabaseModel {}

public protocol DatabaseRepository: Repository {
    var database: Database { get }
    init(database: Database)
}

public extension DatabaseRepository {
    func `for`(_ req: Request) -> Self {
        return Self.init(database: req.db)
    }
}
