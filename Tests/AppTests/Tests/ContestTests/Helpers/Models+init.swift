@testable import App
import Vapor

extension ContestModel {
    convenience init(creator: UUID) {
        self.init(
            creatorID: creator,
            name: "Test contest",
            description: "Test contest description",
            winCondition: .highScore,
            visibility: .public,
            minPlayers: 2,
            maxPlayers: 10,
            instruments: ["stock"],
            markets: ["sp500"],
            startDate: .now + 1.days,
            endDate: .now + 8.days,
            minFund: 2000,
            status: .ready
        )
    }
}

extension UserAccountModel {
    convenience init(hash: String) {
        self.init(
            id: UUID(),
            email: "test@test.com",
            password: hash,
            fullName: "Test User",
            isEmailVerified: true
        )
    }
}
