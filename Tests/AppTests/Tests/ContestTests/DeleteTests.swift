@testable import App
import Entities
import Fluent
import XCTVapor

final class ContestDeleteTests: XCTestCase {
    var app: Application!
    var creator: UserAccountModel!
    var participant: UserAccountModel!
    var contest: ContestModel!
    var testWorld: TestWorld!
    func deletePath(_ id: UUID) -> String {
        "api/contest/\(id)/delete"
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
    
    func testDeleteHappyPath() async throws {
        try await app.repositories.contests.create(contest)
        try await app.repositories.users.create(creator)
        contest.$creator.value = creator
        
        try await app.test(.DELETE, deletePath(contest.id!), user: creator) { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual((app.repositories.contests as! TestContestRepository).contests.count, 0)
        }
    }
    
    func testDeleteNotCreatorShouldFail() async throws {
        try await app.repositories.contests.create(contest)
        try await app.repositories.users.create(creator)
        try await app.repositories.users.create(participant)
        contest.$creator.value = creator
        
        try await app.test(.DELETE, deletePath(contest.id!), user: participant) { response in
            XCTAssertResponseError(response, AuthenticationError.userNotAuthorized)
        }
    }
}
