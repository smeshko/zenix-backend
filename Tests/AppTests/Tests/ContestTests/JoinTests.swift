@testable import App
import Entities
import Fluent
import XCTVapor

extension Contest.Join.Request: Content {}

final class ContestJoinTests: XCTestCase {
    var app: Application!
    var creator: UserAccountModel!
    var participant: UserAccountModel!
    var contest: ContestModel!
    var account: TradingAccountModel!
    var joinRequest: Contest.Join.Request!
    var testWorld: TestWorld!
    func joinPath(_ id: UUID) -> String {
        "api/contest/\(id)/join"
    }
    
    override func setUpWithError() throws {
        app = Application(.testing)
        try configure(app)
        testWorld = try TestWorld(app: app)
        
        creator = try UserAccountModel(hash: app.password.hash("password"))

        participant = try UserAccountModel(
            id: UUID(),
            email: "test2@test.com",
            password: app.password.hash("password"),
            fullName: "Test User 2",
            isEmailVerified: true
        )
        
        account = try TradingAccountModel(id: UUID(), user: participant)
        account.$user.value = participant

        joinRequest = .init(tradingAccountId: account.id!)
        
        contest = ContestModel(creator: creator.id!)
        contest.$creator.value = creator
    }
    
    override func tearDown() {
        app.shutdown()
    }
    
    func testJoinHappyPath() async throws {
        try await app.repositories.users.create(creator)
        try await app.repositories.users.create(participant)
        try await app.repositories.tradingAccounts.create(account)
        try await app.repositories.contests.create(contest)
        
        try await attachContests(1, to: creator)
        
        try await app.test(.POST, joinPath(contest.id!), user: participant, content: joinRequest) { response in
            XCTAssertContent(Contest.Join.Response.self, response) { joinResponse in
                XCTAssertEqual(joinResponse.creator.id, creator.id!)
                XCTAssertEqual(joinResponse.name, contest.name)
            }
        }
    }
    
    func testJoinNonExistingContestShouldFail() async throws {
        try await app.repositories.users.create(participant)
        try await app.repositories.contests.create(contest)
        try await app.repositories.tradingAccounts.create(account)

        try await app.test(.POST, joinPath(UUID()), user: participant, content: joinRequest) { response in
            XCTAssertResponseError(response, ContestError.contestNotFound)
        }
    }
    
    func testJoinAlreadyParticipantShouldFail() async throws {
        try await app.repositories.users.create(creator)
        try await app.repositories.users.create(participant)
        try await app.repositories.tradingAccounts.create(account)
        try await app.repositories.contests.create(contest)
        contest.$participants.value = [participant]
        
        try await app.test(.POST, joinPath(contest.id!), user: participant, content: joinRequest) { response in
            XCTAssertResponseError(response, ContestError.userAlreadyParticipantInContest)
        }
    }
    
    func testJoinCreatorShouldFail() async throws {
        try await app.repositories.users.create(creator)
        try await app.repositories.users.create(participant)
        try await app.repositories.tradingAccounts.create(account)
        try await app.repositories.contests.create(contest)
        contest.$creator.value = creator
        
        try await app.test(.POST, joinPath(contest.id!), user: creator, content: joinRequest) { response in
            XCTAssertResponseError(response, ContestError.userAlreadyParticipantInContest)
        }
    }
    
    func testJoinSameDayAsStartDateShouldFail() async throws {
        try await app.repositories.users.create(participant)
        try await app.repositories.contests.create(contest)
        try await app.repositories.tradingAccounts.create(account)

        contest.startDate = .now
        try await app.test(.POST, joinPath(contest.id!), user: participant, content: joinRequest) { response in
            XCTAssertResponseError(response, ContestError.enrollmentExpired)
        }
    }
    
    func testJoinDayBeforeStartDateAfterMarketClosedShouldFail() async throws {
        try await app.repositories.users.create(participant)
        try await app.repositories.contests.create(contest)
        try await app.repositories.tradingAccounts.create(account)

        app.dataClients.use { _ in .closed }
        
        try await app.test(.POST, joinPath(contest.id!), user: participant, content: joinRequest) { response in
            XCTAssertResponseError(response, ContestError.enrollmentExpired)
        }
    }
    
    func testJoinActiveContestShouldFail() async throws {
        try await app.repositories.users.create(participant)
        try await app.repositories.contests.create(contest)
        try await app.repositories.tradingAccounts.create(account)

        contest.status = .running
        
        try await app.test(.POST, joinPath(contest.id!), user: participant, content: joinRequest) { response in
            XCTAssertResponseError(response, ContestError.enrollmentExpired)
        }
    }
}

private extension MarketClient {
    static var closed: MarketClient {
        .init { .closedForTheDay }
    }
}

private extension ContestJoinTests {
    func attachContests(
        _ count: Int,
        to user: UserAccountModel,
        as role: ContestParticipantModel.Role = .creator
    ) async throws {
        for _ in 0..<count {
            try await app.repositories.contestParticipantss.attach(user, to: contest) { pivot in
                pivot.$tradingAccount.value = self.account
                pivot.role = role
            }
        }
    }
}
