import Framework
import Entities
import Vapor
import Fluent
import JWT

struct UserController {
    func getCurrentUser(_ req: Request) async throws -> User.Account.Detail.Response {
        try .init(from: req.auth.require(UserAccountModel.self))
    }
    
    func delete(_ req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(UserAccountModel.self)
        try await req.users.delete(id: user.requireID())
        return .ok
    }
    
    func list(_ req: Request) async throws -> [User.Account.List.Response] {
        try await req.users.all().map { model in
            try User.Account.List.Response(from: model)
        }
    }
}
