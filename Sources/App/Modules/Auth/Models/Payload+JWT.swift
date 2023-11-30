import Vapor
import Entities
import JWT

private let accessTokenLifetime: Double = 60 * 15

extension Payload: JWTPayload, Authenticatable {
    init(with user: UserAccountModel) throws {
        self.init(
            userID: try user.requireID(),
            fullName: user.fullName,
            email: user.email,
            isAdmin: user.isAdmin,
            expiresAt: Date().addingTimeInterval(accessTokenLifetime)
        )
    }
    
    public func verify(using signer: JWTSigner) throws {
        let claim = ExpirationClaim(value: expiresAt)
        try claim.verifyNotExpired()
    }
}
