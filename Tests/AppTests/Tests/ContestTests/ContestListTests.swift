@testable import App
import Entities
import Fluent
import XCTVapor

final class ContestListTests: XCTestCase {
    var app: Application!
    var creator: UserAccountModel!
    var participant: UserAccountModel!
    var contest: ContestModel!
    var testWorld: TestWorld!
    var listPath: String = "api/contest/list"

    override func setUpWithError() throws {
        app = Application(.testing)
        try configure(app)
        testWorld = try TestWorld(app: app)
        
        creator = try UserAccountModel(
            id: UUID(),
            email: "test@test.com",
            password: app.password.hash("password"),
            fullName: "Test User",
            isEmailVerified: true
        )
        
        participant = try UserAccountModel(
            email: "test2@test.com",
            password: app.password.hash("password"),
            fullName: "Test User 2",
            isEmailVerified: true
        )

        contest = ContestModel(
            creatorID: creator.id!,
            name: "Test contest",
            description: "Test contest description",
            winCondition: .highScore,
            visibility: .public,
            minPlayers: 2,
            maxPlayers: 10,
            instruments: ["stock"],
            markets: ["sp500"],
            duration: 7.days,
            startDate: .now,
            endDate: .now + 7.days,
            minFund: 2000
        )
    }
    
    override func tearDown() {
        app.shutdown()
    }
    
    func testListHappyPath() async throws {
        try await app.repositories.contests.create(contest)
        
        try app.test(.GET, listPath) { response in
            XCTAssertContent([Contest.List.Response].self, response) { list in
                XCTAssertEqual(list.count, 1)
                XCTAssertEqual(list[0].name, contest.name)
            }
        }
    }
}
