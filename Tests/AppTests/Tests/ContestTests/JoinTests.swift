@testable import App
import Entities
import Fluent
import XCTVapor

final class ContestJoinTests: XCTestCase {
    var app: Application!
    var creator: UserAccountModel!
    var participant: UserAccountModel!
    var contest: ContestModel!
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
            email: "test2@test.com",
            password: app.password.hash("password"),
            fullName: "Test User 2",
            isEmailVerified: true
        )
        
        contest = ContestModel(creator: creator.id!)
    }
    
    override func tearDown() {
        app.shutdown()
    }
    
    func testJoinHappyPath() async throws {
        try await app.repositories.users.create(creator)
        try await app.repositories.users.create(participant)
        try await app.repositories.contests.create(contest)
        contest.$creator.value = creator
        
        try await app.test(.POST, joinPath(contest.id!), user: participant) { response in
            XCTAssertContent(Contest.Join.Response.self, response) { joinResponse in
                XCTAssertEqual(joinResponse.creator.id, creator.id!)
                XCTAssertEqual(joinResponse.name, contest.name)
            }
        }
    }
    
    func testJoinNonExistingContestShouldFail() async throws {
        try await app.repositories.users.create(participant)
        try await app.repositories.contests.create(contest)
        
        try await app.test(.POST, joinPath(UUID()), user: participant) { response in
            XCTAssertResponseError(response, ContestError.contestNotFound)
        }
    }
    
    func testJoinAlreadyParticipantShouldFail() async throws {
        try await app.repositories.users.create(creator)
        try await app.repositories.users.create(participant)
        try await app.repositories.contests.create(contest)
        try await app.repositories.contests.attach(participant, to: contest)
        contest.$creator.value = creator
        
        try await app.test(.POST, joinPath(contest.id!), user: participant) { response in
            XCTAssertResponseError(response, ContestError.userAlreadyParticipantInContest)
        }
    }
    
    func testJoinCreatorShouldFail() async throws {
        try await app.repositories.users.create(creator)
        try await app.repositories.users.create(participant)
        try await app.repositories.contests.create(contest)
        try await app.repositories.contests.attach(creator, to: contest)
        contest.$creator.value = creator
        
        try await app.test(.POST, joinPath(contest.id!), user: creator) { response in
            XCTAssertResponseError(response, ContestError.userAlreadyParticipantInContest)
        }
    }
    
    func testJoinSameDayAsStartDateShouldFail() async throws {
        try await app.repositories.users.create(participant)
        try await app.repositories.contests.create(contest)

        contest.startDate = .now
        try await app.test(.POST, joinPath(contest.id!), user: participant) { response in
            XCTAssertResponseError(response, ContestError.enrollmentExpired)
        }
    }
    
    func testJoinDayBeforeStartDateAfterMarketClosedShouldFail() async throws {
        try await app.repositories.users.create(participant)
        try await app.repositories.contests.create(contest)
        
        app.dataClients.use { _ in .closed }
        
        try await app.test(.POST, joinPath(contest.id!), user: participant) { response in
            XCTAssertResponseError(response, ContestError.enrollmentExpired)
        }
    }
    
    func testJoinActiveContestShouldFail() async throws {
        try await app.repositories.users.create(participant)
        try await app.repositories.contests.create(contest)
        
        contest.status = .running
        
        try await app.test(.POST, joinPath(contest.id!), user: participant) { response in
            XCTAssertResponseError(response, ContestError.enrollmentExpired)
        }
    }
}

private extension MarketClient {
    static var closed: MarketClient {
        .init { .closedForTheDay }
    }
}
