@testable import App
import Entities
import Fluent
import XCTVapor

extension Contest.Create.Request: Content {}

final class ContestCreateTests: XCTestCase {
    var app: Application!
    var user: UserAccountModel!
    var user2: UserAccountModel!
    var account: TradingAccountModel!
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
        account = try TradingAccountModel(id: UUID(), user: user)
        account.$user.value = user

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
            minFund: 2000,
            tradingAccountId: account.id!
        )
        
        existingContest = ContestModel(creator: user.id!)
    }
    
    override func tearDown() {
        app.shutdown()
    }
    
    func testCreateHappyPath() async throws {
        try await app.repositories.users.create(user)
        try await app.repositories.tradingAccounts.create(account)
        
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
        try await app.repositories.tradingAccounts.create(account)
        try await app.repositories.contests.create(existingContest)
        
        try await attachContests(3, to: user)

        try await app.test(.POST, createPath, user: user, content: contest) { response in
            XCTAssertResponseError(response, ContestError.maxNumberOfContestsExceeded)
        }
    }
    
    func testCreate6thContestShouldFail() async throws {
        try await app.repositories.users.create(user)
        try await app.repositories.users.create(user2)
        try await app.repositories.tradingAccounts.create(account)
        try await app.repositories.contests.create(existingContest)

        try await attachContests(5, to: user, as: .participant)

        try await app.test(.POST, createPath, user: user, content: contest) { response in
            XCTAssertResponseError(response, ContestError.maxNumberOfContestsExceeded)
        }
    }
    
    func testCreateSchedulingConflictShouldFail() async throws {
        try await app.repositories.users.create(user)
        try await app.repositories.tradingAccounts.create(account)
        try await app.repositories.contests.create(existingContest)

        try await attachContests(1, to: user)

        try await app.test(.POST, createPath, user: user, content: contest) { response in
            XCTAssertResponseError(response, ContestError.schedulingConflict)
        }
    }
}

private extension ContestCreateTests {
    func attachContests(
        _ count: Int,
        to user: UserAccountModel,
        as role: ContestParticipantModel.Role = .creator
    ) async throws {
        for _ in 0..<count {
            try await app.repositories.contestParticipantss.attach(user, to: existingContest) { pivot in
                pivot.$tradingAccount.value = self.account
                pivot.role = role
            }
        }
    }
}
