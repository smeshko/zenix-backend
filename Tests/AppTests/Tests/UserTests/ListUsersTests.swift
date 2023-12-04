@testable import App
import Entities
import Fluent
import XCTVapor

final class ListUsersTests: XCTestCase {
    var app: Application!
    var user: UserAccountModel!
    var testWorld: TestWorld!
    let listPath = "api/user/list"
    
    override func setUpWithError() throws {
        app = Application(.testing)
        try configure(app)
        testWorld = try TestWorld(app: app)
        
        user = try UserAccountModel(
            email: "test@test.com",
            password: app.password.hash("password"),
            fullName: "Test User",
            isAdmin: true,
            isEmailVerified: true
        )
    }
    
    override func tearDown() {
        app.shutdown()
    }
    
    func testListHappyPath() async throws {
        try await app.repositories.users.create(user)
        try await app.test(.GET, listPath, user: user) { response in
            XCTAssertContent([User.Account.List.Response].self, response) { listResponse in
                XCTAssertEqual(listResponse.count, 1)
            }
        }
    }
    
    func testListRequestedByNonAdminShouldFail() async throws {
        let nonAdmin = try UserAccountModel(
            email: "test@test.com",
            password: app.password.hash("password"),
            fullName: "Test User",
            isEmailVerified: true
        )
        try await app.repositories.users.create(nonAdmin)
        try await app.test(.GET, listPath, user: nonAdmin) { response in
            XCTAssertEqual(response.status, .unauthorized)
        }
    }
    
    func testListUnauthenticatedRequestShouldFail() async throws {
        try app.test(.GET, listPath) { response in
            XCTAssertEqual(response.status, .unauthorized)
        }
    }
}
