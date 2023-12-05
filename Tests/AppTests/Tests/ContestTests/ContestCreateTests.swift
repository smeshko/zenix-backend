@testable import App
import Entities
import Fluent
import XCTVapor

extension Contest.Create.Request: Content {}

final class ContestCreateTests: XCTestCase {
    var app: Application!
    var user: UserAccountModel!
    var contest: Contest.Create.Request!
    var testWorld: TestWorld!
    let createPath = "api/contest/create"
    
    override func setUpWithError() throws {
        app = Application(.testing)
        try configure(app)
        testWorld = try TestWorld(app: app)
        
        user = try UserAccountModel(
            email: "test@test.com",
            password: app.password.hash("password"),
            fullName: "Test User",
            isEmailVerified: true
        )

        contest = Contest.Create.Request(
            name: "Test contest",
            description: "Test contest description",
            winCondition: .highScore,
            targetProfitRatio: nil,
            visibility: .public,
            minPlayers: 2,
            maxPlayers: 10,
            instruments: [.stock],
            markets: [.nasdaq, .sp500],
            duration: .week,
            startDate: .now,
            minFund: 2000
        )
    }
    
    override func tearDown() {
        app.shutdown()
    }
    
    func testCreateHappyPath() async throws {
        try await app.repositories.users.create(user)
        
        try await app.test(.POST, createPath, user: user, content: contest) { response in
            XCTAssertContent(Contest.Create.Response.self, response) { contestResponse in
                XCTAssertEqual(contestResponse.name, contest.name)
                XCTAssertEqual(contestResponse.description, contest.description)
                XCTAssertEqual(contestResponse.minPlayers, contest.minPlayers)
                let sameDay = Calendar.current.isDate(
                    contestResponse.endDate,
                    equalTo: contest.startDate + 7.days,
                    toGranularity: .day
                )
                XCTAssertTrue(sameDay)
                XCTAssertEqual(contestResponse.creator.email, user.email)
            }
        }
    }
}
