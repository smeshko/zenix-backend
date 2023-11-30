import Vapor
import Entities
import Foundation

extension User.Auth.Login.Response: Content {}

extension User.Auth.Create.Response: Content {
    init(from model: UserAccountModel, token: RefreshTokenModel, on req: Request) throws {
        self.init(
            token: try .init(from: token, user: model, on: req),
            user: try .init(from: model)
        )
    }
}
