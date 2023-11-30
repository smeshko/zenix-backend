import Framework
import Entities
import Vapor
import Fluent

struct UserController {
    
    func getCurrentUser(_ req: Request) async throws -> User.Account.Detail.Response {
        let payload = try req.auth.require(Payload.self)
        
        guard let user = try await req.users.find(id: payload.userID) as? UserAccountModel else {
            throw AuthenticationError.userNotFound
        }
        return try .init(from: user)
    }
    
    func delete(_ req: Request) async throws -> HTTPStatus {
        let payload = try req.auth.require(Payload.self)
        
        guard let user = try await req.users.find(id: payload.userID) as? UserAccountModel else {
            throw AuthenticationError.userNotFound
        }

        try await req.users.delete(id: user.requireID())
        return .ok
    }
    
    func list(_ req: Request) async throws -> [User.Account.List.Response] {
        try await UserAccountModel.query(on: req.db).all()
            .map { model in
                try User.Account.List.Response(from: model)
            }
    }
}
