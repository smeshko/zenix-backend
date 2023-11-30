@testable import App
import Entities
import Fluent
import XCTVapor
import Crypto

extension User.Auth.Create.Request: Content {}

final class RegisterTests: XCTestCase {
    var app: Application!
    var testWorld: TestWorld!
    let registerPath = "api/auth/sign-up"
    
    override func setUpWithError() throws {
        app = Application(.testing)
        try configure(app)
        self.testWorld = try TestWorld(app: app)
    }
    
    override func tearDown() {
        app.shutdown()
    }
    
    func testRegisterHappyPath() async throws {
        app.randomGenerators.use(.rigged(value: "token"))
        
        let data = User.Auth.Create.Request(
            email: "test@test.com",
            password: "password123",
            fullName: "Test User"
        )
        
        try app.test(.POST, registerPath, beforeRequest: { req in
            try req.content.encode(data)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertContent(User.Auth.Create.Response.self, res) { signup in
                XCTAssertEqual(signup.user.email, "test@test.com")
                XCTAssertEqual(signup.user.fullName, "Test User")
                XCTAssert(!signup.token.refreshToken.isEmpty)
                XCTAssert(!signup.token.accessToken.isEmpty)
            }

//            let emailToken = try await app.repositories.emailTokens.find(token: SHA256.hash("token"))
//            XCTAssertEqual(emailToken?.$user.id, user.id)
//            XCTAssertNotNil(emailToken)
            
//            let job = try XCTUnwrap(app.queues.test.first(EmailJob.self))
//            XCTAssertEqual(job.recipient, "test@test.com")
//            XCTAssertEqual(job.email.templateName, "email_verification")
//            XCTAssertEqual(job.email.templateData["verify_url"], "http://api.local/auth/email-verification?token=token")
        })
    }
    
    func testRegisterFailsWithExistingEmail() async throws {
        try await app.autoMigrate()
        defer { try! app.autoRevert().wait() }

        app.repositories.use(.database)
        
        let user = UserAccountModel(
            email: "test@test.com",
            password: "123",
            fullName: "Test user 1"
        )

        try await user.create(on: app.db)

        let registerRequest = User.Auth.Create.Request(
            email: "test@test.com",
            password: "password123",
            fullName: "Test User 2"
        )
        
        try await app.test(.POST, registerPath, beforeRequest: { req in
            try req.content.encode(registerRequest)
        }, afterResponse: { res in
            XCTAssertResponseError(res, AuthenticationError.emailAlreadyExists)
            let users = try await UserAccountModel.query(on: app.db).all()
            XCTAssertEqual(users.count, 1)
        })
    }
}

