import Entities
@testable import App
import XCTVapor

let uuid = "123e4567-e89b-12d3-a456-426614174000"

final class ContestControllerTests: AppTestCase {
    
    func testCreateContest_MarksUserAsCreator() async throws {
        let app = try createTestApp()
        defer { app.shutdown() }
        
        let token = try authenticateRoot(app)
        let contest = Contest.Create.mock()
        
        try app.testable(method: .inMemory)
            .test(
                .POST, "/api/contest/create", 
                headers: HTTPHeaders([bearerHeader(token.value)]), content: contest
            )
        { response in
            let receivedContest = try response.content.decode(Contest.Detail.self)
            XCTAssertNotNil(receivedContest.id)
            XCTAssertEqual(receivedContest.creator.id, token.user.id)
        }
    }
    
    func testJoinContest_ShouldSucceed() async throws {
        let app = try createTestApp()
        defer { app.shutdown() }
        
        let token = try create(.mock(), app)
        let contest = try await seedContest(app)
        
        try app.testable(method: .inMemory)
            .test(
                .POST, "/api/contest/\(contest.id)/join",
                headers: HTTPHeaders([bearerHeader(token.value)])
            )
        { response in
            let receivedContest = try response.content.decode(Contest.Detail.self)
            XCTAssertNotNil(receivedContest.id)
            XCTAssertTrue(receivedContest.participants.map(\.id).contains(token.user.id))
        }
    }
    
    func testJoinContest_IfAlreadyParticipant_ShouldFail() async throws {
        let app = try createTestApp()
        defer { app.shutdown() }
        
        let token = try authenticateRoot(app)
        let contest = try await seedContest(app)
        
        try app.testable(method: .inMemory)
            .test(
                .POST, "/api/contest/\(contest.id)/join",
                headers: HTTPHeaders([bearerHeader(token.value)])
            )
        { response in
            XCTAssertEqual(response.status, .badRequest)
        }
    }
    
    func testLeaveContest_ShouldSucceed() async throws {
        let app = try createTestApp()
        defer { app.shutdown() }
        
        let token = try create(.mock(), app)
        let contest = try await seedContest(app)
        try await join(contest.id, userToken: token.value, app: app)
        
        try app.testable(method: .inMemory)
            .test(
                .POST, "/api/contest/\(contest.id)/leave",
                headers: HTTPHeaders([bearerHeader(token.value)])
            )
        { response in
            XCTAssertEqual(response.status, .ok)
        }
    }
    
    func testLeaveContest_IfNotParticipant_ShouldFail() async throws {
        let app = try createTestApp()
        defer { app.shutdown() }
        
        let token = try create(.mock(), app)
        let contest = try await seedContest(app)
        
        try app.testable(method: .inMemory)
            .test(
                .POST, "/api/contest/\(contest.id)/leave",
                headers: HTTPHeaders([bearerHeader(token.value)])
            )
        { response in
            XCTAssertEqual(response.status, .badRequest)
        }
    }
    
    func testLeaveContest_IfCreator_ShouldFail() async throws {
        let app = try createTestApp()
        defer { app.shutdown() }
        
        let rootToken = try authenticateRoot(app)
        let contest = try await seedContest(app)
        
        try app.testable(method: .inMemory)
            .test(
                .POST, "/api/contest/\(contest.id)/leave",
                headers: HTTPHeaders([bearerHeader(rootToken.value)])
            )
        { response in
            XCTAssertEqual(response.status, .badRequest)
        }
    }
    
    func testDeleteContest_ShouldFail() async throws {
        let app = try createTestApp()
        defer { app.shutdown() }
        
        let rootToken = try authenticateRoot(app)
        let contest = try await seedContest(app)
        
        try app.testable(method: .inMemory)
            .test(
                .DELETE, "/api/contest/\(contest.id)/delete",
                headers: HTTPHeaders([bearerHeader(rootToken.value)])
            )
        { response in
            XCTAssertEqual(response.status, .ok)
        }
    }
    
    func testDeleteContest_IfNotCreator_ShouldFail() async throws {
        let app = try createTestApp()
        defer { app.shutdown() }
        
        let token = try create(.mock(), app)
        let contest = try await seedContest(app)
        
        try app.testable(method: .inMemory)
            .test(
                .DELETE, "/api/contest/\(contest.id)/delete",
                headers: HTTPHeaders([bearerHeader(token.value)])
            )
        { response in
            XCTAssertEqual(response.status, .unauthorized)
        }
    }
    
    private func seedContest(_ app: Application) async throws -> Contest.Detail {
        let token = try authenticateRoot(app)
        let contest = Contest.Create.mock()
        var createdContest: Contest.Detail!
        
        try app.testable(method: .inMemory)
            .test(
                .POST, "/api/contest/create",
                headers: HTTPHeaders([bearerHeader(token.value)]), content: contest
            )
        { response in
            createdContest = try response.content.decode(Contest.Detail.self)
        }
        return createdContest
    }
    
    private func join(_ contestId: UUID, userToken: String, app: Application) async throws {
        try await app.testable(method: .inMemory)
            .test(
                .POST, "/api/contest/\(contestId)/join",
                headers: HTTPHeaders([bearerHeader(userToken)])
            )
    }
}

private extension Contest.Create {
    static func mock() -> Contest.Create {
        .init(
            name: "Test",
            description: "Test contest",
            winCondition: .highScore,
            targetProfitRatio: nil,
            visibility: .public,
            minPlayers: 2,
            maxPlayers: 5,
            minUserLevel: 0,
            instruments: [.stock],
            markets: [.sp500],
            duration: 7.days,
            startDate: .now,
            endDate: .now + 7.days,
            marginAllowed: true,
            minFund: 2000,
            tradesLimit: 500
        )
    }
}

private extension Contest.Detail {
    static func mock() -> Contest.Detail {
        .init(
            id: UUID(uuidString: uuid)!,
            name: "Test",
            description: "Test contest",
            creator: User.Account.Detail.mock(),
            participants: [],
            winCondition: .highScore,
            targetProfitRatio: nil,
            visibility: .public,
            minPlayers: 2,
            maxPlayers: 5,
            minUserLevel: 0,
            instruments: [.stock],
            markets: [.sp500],
            duration: 7.days,
            startDate: .now,
            endDate: .now + 7.days,
            marginAllowed: true,
            minFund: 2000,
            tradesLimit: 500
        )
    }
}

private extension User.Account.Detail {
    static func mock() -> User.Account.Detail {
        .init(
            id: UUID(uuidString: uuid)!,
            email: "mock@jock.com",
            status: .notAccepting,
            level: 0
        )
    }
}

private extension User.Account.Create {
    static func mock() -> User.Account.Create {
        .init(email: "mock@jock.com", password: "password")
    }
}
