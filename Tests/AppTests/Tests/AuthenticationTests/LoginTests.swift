@testable import App
import Entities
import Fluent
import XCTVapor
import Crypto

extension User.Auth.Login.Request: Content {}

final class LoginTests: XCTestCase {
    var app: Application!
    var testWorld: TestWorld!
    let loginPath = "api/auth/sign-in"
    
    override func setUpWithError() throws {
        app = Application(.testing)
        try configure(app)
        testWorld = try TestWorld(app: app)
    }
    
    override func tearDown() {
        app.shutdown()
    }
    
    func testLoginHappyPath() async throws {
        app.passwords.use(.plaintext)
        
        let user = try UserAccountModel(
            email: "test@test.com",
            password: app.password.hash("password"),
            fullName: "Test User",
            isEmailVerified: true
        )
        
        try await app.repositories.users.create(user)
        let loginRequest = User.Auth.Login.Request(email: "test@test.com", password: "password")
        
        try app.test(.POST, loginPath, beforeRequest: { req in
            try req.content.encode(loginRequest)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertContent(User.Auth.Login.Response.self, res) { login in
                XCTAssertEqual(login.user.email, "test@test.com")
                XCTAssertEqual(login.user.fullName, "Test User")
                XCTAssert(!login.token.refreshToken.isEmpty)
                XCTAssert(!login.token.accessToken.isEmpty)
            }
        })
    }
    
    func testLoginWithNonExistingUserFails() throws {
        let loginRequest = User.Auth.Login.Request(email: "none@login.com", password: "123")
        
        try app.test(.POST, loginPath, beforeRequest: { req in
            try req.content.encode(loginRequest)
        }, afterResponse: { res in
            XCTAssertResponseError(res, AuthenticationError.invalidEmailOrPassword)
        })
    }
    
    func testLoginWithIncorrectPasswordFails() async throws {
        app.passwords.use(.plaintext)

        let user = UserAccountModel(
            email: "test@test.com",
            password: "password",
            fullName: "Test User",
            isEmailVerified: true
        )

        try await app.repositories.users.create(user)
        
        let loginRequest = User.Auth.Login.Request(email: "test@test.com", password: "wrongpassword")
        
        try app.test(.POST, loginPath, beforeRequest: { req in
            try req.content.encode(loginRequest)
        }, afterResponse: { res in
            XCTAssertResponseError(res, AuthenticationError.invalidEmailOrPassword)
        })
    }
    
    func testLoginRequiresEmailVerification() async throws {
        app.passwords.use(.plaintext)
        
        let user = UserAccountModel(
            email: "test@test.com",
            password: "password",
            fullName: "Test User",
            isEmailVerified: false
        )

        try await app.repositories.users.create(user)
        
        let loginRequest = User.Auth.Login.Request(email: "test@test.com", password: "password")
        
        try app.test(.POST, loginPath, beforeRequest: { req in
            try req.content.encode(loginRequest)
        }, afterResponse: { res in
            XCTAssertResponseError(res, AuthenticationError.emailIsNotVerified)
        })
    }
    
    func testLoginDeletesOldRefreshTokens() async throws {
        app.passwords.use(.plaintext)
        
        let user = UserAccountModel(
            email: "test@test.com",
            password: "password",
            fullName: "Test User",
            isEmailVerified: true
        )

        try await app.repositories.users.create(user)
        
        let loginRequest = User.Auth.Login.Request(email: "test@test.com", password: "password")
        let token = app.random.generate(bits: 256)
        
        let refreshToken = try RefreshTokenModel(value: SHA256.hash(token), userID: user.requireID())
        try await app.repositories.refreshTokens.create(refreshToken)
        
        try await app.test(.POST, loginPath, beforeRequest: { req in
            try req.content.encode(loginRequest)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let tokenCount = try await app.repositories.refreshTokens.count()
            XCTAssertEqual(tokenCount, 1)
        })
    }
}
