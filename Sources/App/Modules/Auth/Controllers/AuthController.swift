import Entities
import Vapor
import Fluent

struct AuthController {
    
    func signIn(_ req: Request) async throws -> User.Auth.Login.Response {
        let user = try req.auth.require(UserAccountModel.self)
        try await req.refreshTokens.delete(forUserID: try user.requireID())
        
        let token = req.random.generate(bits: 256)
        let refreshToken = RefreshTokenModel(value: SHA256.hash(token), userID: try user.requireID())
        
        try await req.refreshTokens.create(refreshToken)

        return User.Auth.Login.Response(
            token: try .init(from: refreshToken, user: user, on: req),
            user: try .init(from: user)
        )
    }
    
    func signUp(_ req: Request) async throws -> User.Auth.Create.Response {
        try User.Auth.Create.Request.validate(content: req)
        let registerRequest = try req.content.decode(User.Auth.Create.Request.self)

        let hash = try await req.password.async.hash(registerRequest.password)
        let user = UserAccountModel(
            email: registerRequest.email.lowercased(),
            password: hash,
            fullName: registerRequest.fullName
        )
        
        do {
            try await req.users.create(user)
        } catch is DatabaseError {
            throw AuthenticationError.emailAlreadyExists
        }
        
        let token = req.random.generate(bits: 256)
        let refreshToken = RefreshTokenModel(value: SHA256.hash(token), userID: try user.requireID())
        
        try await req.refreshTokens.create(refreshToken)
        try await req.emailVerifier.verify(for: user)
        
        return User.Auth.Create.Response(
            token: try .init(from: refreshToken, user: user, on: req),
            user: try .init(from: user)
        )
    }
    
    func refreshAccessToken(_ req: Request) async throws -> User.Token.Refresh.Response {
        let accessTokenRequest = try req.content.decode(User.Token.Refresh.Request.self)
        let hashedRefreshToken = SHA256.hash(accessTokenRequest.refreshToken)
        
        guard let token = try await req.refreshTokens.find(token: hashedRefreshToken) else {
            throw AuthenticationError.refreshTokenOrUserNotFound
        }
        
        guard token.expiresAt > .now else {
            throw AuthenticationError.refreshTokenHasExpired
        }
        
        guard let user = try await req.users.find(id: token.$user.id) else {
            throw AuthenticationError.userNotFound
        }
        
        try await req.refreshTokens.delete(id: token.requireID())
        
        let generatedToken = req.random.generate(bits: 256)
        let newRefreshToken = try RefreshTokenModel(value: SHA256.hash(generatedToken), userID: user.requireID())
        
        let payload = try Payload(with: user)
        let accessToken = try req.jwt.sign(payload)
        
        try await req.refreshTokens.create(newRefreshToken)
        return .init(
            refreshToken: generatedToken,
            accessToken: accessToken
        )
    }
    
    func logout(_ req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(UserAccountModel.self)
        try await req.refreshTokens.delete(forUserID: user.requireID())
        return .ok
    }
}
