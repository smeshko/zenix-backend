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
    
    func patch(_ req: Request) async throws -> User.Account.Patch.Response {
        let request = try req.content.decode(User.Account.Patch.Request.self)
        let user = try req.auth.require(UserAccountModel.self)
        
        if let email = request.email {
            user.email = email
        }
        
        if let name = request.fullName {
            user.fullName = name
        }
        
        if let status = request.status {
            user.challengeStatus = status.db
        }
        
        try await req.users.update(user)
        return try .init(from: user)
    }
}
