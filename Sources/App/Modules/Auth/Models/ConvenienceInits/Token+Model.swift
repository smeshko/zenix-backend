import Entities
import Vapor

extension User.Token.Refresh.Response: Content {
    init(
        from model: RefreshTokenModel, 
        user: UserAccountModel,
        on req: Request
    ) throws {
        self.init(
            refreshToken: model.value,
            accessToken: try req.jwt.sign(Payload(with: user))
        )
    }
}
