import Vapor
import Fluent
import Entities

public protocol RequestService {
    func `for`(_ req: Request) -> Self
}

public protocol Repository: RequestService {
    associatedtype Model: DatabaseModelInterface
    
    func delete(id: UUID) async throws
    func count() async throws -> Int
}

public extension Repository where Self: DatabaseRepository {
    func delete(id: UUID) async throws {
        try await Model.find(id, on: database)?
            .delete(on: database)
    }
    
    func count() async throws -> Int {
        try await Model.query(on: database).count()
    }
}

public protocol DatabaseRepository: Repository {
    var database: Database { get }
    init(database: Database)
}

public extension DatabaseRepository {
    func `for`(_ req: Request) -> Self {
        return Self.init(database: req.db)
    }
}
//public protocol TokenDatabaseModel: DatabaseModelInterface {
//    associatedtype User: DatabaseModelInterface & Fluent.Model
//    
//    static var userKeyPath: KeyPath<Self, Fluent.ParentProperty<Self, User>> { get }
//    var value: String { get set }
//}
//
//public extension TokenDatabaseModel {
//    var user: User {
//        get { self[keyPath: Self.userKeyPath].wrappedValue }
//        set {
//            self[keyPath: Self.userKeyPath].value = newValue
//            self[keyPath: Self.userKeyPath].id = newValue.id
//        }
//    }
//}
//
//public extension TokenRepository where Self: DatabaseRepository, Model: TokenDatabaseModel {
//    func find(forUserID id: UUID) async throws -> Model? {
//        try await Model.query(on: database)
//            .filter(Model.userKeyPath.appending(path: \.$id) == id)
//            .first()
//    }
//}
//
//final class MyModel: TokenDatabaseModel, Fluent.Model {
//    static var userKeyPath: KeyPath<Self, Fluent.ParentProperty<Self, User>> {
//        \.$user
//    }
//
//    @Parent(key: "user_id")
//    var user: User
//}
