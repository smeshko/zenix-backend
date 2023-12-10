import Entities
import Vapor

extension User.Token.Refresh.Response: Content {
    init(
        token: String,
        user: UserAccountModel,
        on req: Request
    ) throws {
        self.init(
            refreshToken: token,
            accessToken: try req.jwt.sign(Payload(with: user))
        )
    }
}
