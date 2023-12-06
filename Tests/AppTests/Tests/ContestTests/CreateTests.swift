@testable import App
import Entities
import Fluent
import XCTVapor

extension Contest.Create.Request: Content {}

final class ContestCreateTests: XCTestCase {
    var app: Application!
    var user: UserAccountModel!
    var user2: UserAccountModel!
    var contest: Contest.Create.Request!
    var existingContest: ContestModel!
    var testWorld: TestWorld!
    let createPath = "api/contest/create"
    
    override func setUpWithError() throws {
        app = Application(.testing)
        try configure(app)
        testWorld = try TestWorld(app: app)
        
        user = try UserAccountModel(hash: app.password.hash("password"))
        user2 = try UserAccountModel(hash: app.password.hash("password"))

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
        
        existingContest = ContestModel(creator: user.id!)
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
            }
        }
    }
    
    func testCreate4thContestShouldFail() async throws {
        try await app.repositories.users.create(user)
                
        existingContest.$creator.value = user
        user.$contests.value = [existingContest, existingContest, existingContest]

        try await app.test(.POST, createPath, user: user, content: contest) { response in
            XCTAssertResponseError(response, ContestError.maxNumberOfContestsExceeded)
        }
    }
    
    func testCreate6thContestShouldFail() async throws {
        try await app.repositories.users.create(user)
        try await app.repositories.users.create(user2)
        
        existingContest.$creator.value = user2
        existingContest.$participants.value = [user]
        user.$contests.value = [existingContest, existingContest, existingContest, existingContest, existingContest]

        try await app.test(.POST, createPath, user: user, content: contest) { response in
            XCTAssertResponseError(response, ContestError.maxNumberOfContestsExceeded)
        }
    }
    
    func testCreateSchedulingConflictShouldFail() async throws {
        try await app.repositories.users.create(user)
        
        existingContest.$creator.value = user
        user.$contests.value = [existingContest]

        try await app.test(.POST, createPath, user: user, content: contest) { response in
            XCTAssertResponseError(response, ContestError.schedulingConflict)
        }
    }
}
