@testable import App
import Entities
import XCTVapor
import FluentSQLiteDriver

extension User.Account.Login: Content {}

class AppTestCase: XCTestCase {
    
    func bearerHeader(_ token: String) -> (String, String) {
        ("Authorization", "Bearer \(token)")
    }
    
    func createTestApp() throws -> Application {
        let app = Application(.testing)
        
        try configure(app)
        app.databases.reinitialize()
        app.databases.use(.sqlite(.memory), as: .sqlite)
        app.databases.default(to: .sqlite)
        try app.autoMigrate().wait()
        return app
    }
    
    func create(
        _ user: User.Account.Create,
        _ app: Application
    ) throws -> User.Token.Detail {
        var userDetail: User.Token.Detail?
        
        try app.testable(method: .inMemory)
            .test(.POST, "/api/user/sign-up", content: user)
        { response in
            XCTAssertContent(User.Token.Detail.self, response) { content in
                userDetail = content
            }
        }
        guard let result = userDetail else {
            XCTFail("Signup failed")
            throw Abort(.unauthorized)
        }
        return result

    }
    
    func authenticate(
        _ user: User.Account.Login,
        _ app: Application
    ) throws -> User.Token.Detail {
        var token: User.Token.Detail?
        try app.test(.POST, "/api/user/sign-in/", beforeRequest: { req in
            try req.content.encode(user)
        }, afterResponse: { res in
            XCTAssertContent(User.Token.Detail.self, res) { content in
                token = content
            }
        })
        guard let result = token else {
            XCTFail("Login failed")
            throw Abort(.unauthorized)
        }
        return result
    }
    
    func authenticateRoot(
        _ app: Application
    ) throws -> User.Token.Detail {
        try authenticate(
            .init(
                email: "root@localhost.com",
                password: "ChangeMe1"
            ),
            app
        )
    }
}
