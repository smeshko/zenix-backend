import Entities
@testable import App
import XCTVapor

extension User.Account.Create: Content {}

final class UserControllerTests: AppTestCase {
    
    func testSignUpWithValidCredentials_IsSuccessful() async throws {
        let app = try createTestApp()
        defer { app.shutdown() }
        
        let user = User.Account.Create(
            email: "ivot@spotify.com",
            password: "password!"
        )
        
        try app.testable(method: .inMemory)
            .test(.POST, "/api/user/sign-up", content: user)
        { response in
            let receivedUser = try response.content.decode(User.Token.Detail.self)
            XCTAssertNotNil(receivedUser.id)
        }
    }
    
    func testSignUpWithInValidPassword_IsNotSuccessful() async throws {
        let app = try createTestApp()
        defer { app.shutdown() }
        
        let user = User.Account.Create(
            email: "ivot@spotify.com",
            password: "pass"
        )
        
        try app.testable(method: .inMemory)
            .test(.POST, "/api/user/sign-up", content: user)
        { response in
            XCTAssertEqual(response.status, .badRequest)
        }
    }
    
    func testSignUpWithInValidEmail_IsNotSuccessful() async throws {
        let app = try createTestApp()
        defer { app.shutdown() }
        
        let user = User.Account.Create(
            email: "ivotspotify.com",
            password: "password!"
        )
        
        try app.testable(method: .inMemory)
            .test(.POST, "/api/user/sign-up", content: user)
        { response in
            XCTAssertEqual(response.status, .badRequest)
        }
    }
    
    func testLogout_ShouldDeleteToken() async throws {
        let app = try createTestApp()
        defer { app.shutdown() }
        
        let token = try authenticateRoot(app)
        
        try app.testable(method: .inMemory)
            .test(
                .POST, "/api/user/logout",
                headers: HTTPHeaders([bearerHeader(token.value)])
            ) { response in
                let tokens = try UserTokenModel.query(on: app.db).all().wait()
                XCTAssertEqual(response.status, .ok)
                XCTAssertEqual(tokens.count, 0)
            }
    }
    
    func testDelete_ShouldDeleteUser() async throws {
        let app = try createTestApp()
        defer { app.shutdown() }
        
        let token = try authenticateRoot(app)
        
        try app.testable(method: .inMemory)
            .test(
                .DELETE, "/api/user/delete",
                headers: HTTPHeaders([bearerHeader(token.value)])
            ) { response in
                let users = try UserAccountModel.query(on: app.db).all().wait()
                XCTAssertEqual(response.status, .ok)
                XCTAssertEqual(users.count, 0)
            }
    }
}
