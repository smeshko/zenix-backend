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
            startDate: .now,
            endDate: .now + 7.days,
            minFund: 2000
        )
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
                XCTAssertEqual(joinResponse.participants.count, 1)
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
}
