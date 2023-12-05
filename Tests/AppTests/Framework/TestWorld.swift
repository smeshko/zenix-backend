@testable import App
import Fluent
import FluentSQLiteDriver
import XCTVapor
import XCTQueues

class TestWorld {
    let app: Application
    
    // Repositories
    private var tokenRepository: TestRefreshTokenRepository
    private var userRepository: TestUserRepository
    private var emailTokenRepository: TestEmailTokenRepository
    private var passwordTokenRepository: TestPasswordTokenRepository
    private var contestRepository: TestContestRepository
    
    private var refreshtokens: [RefreshTokenModel] = []
    private var users: [UserAccountModel] = []
    private var emailTokens: [EmailTokenModel] = []
    private var passwordTokens: [PasswordTokenModel] = []
    private var contests: [ContestModel] = []
    
    init(app: Application) throws {
        self.app = app
        
        try app.jwt.signers.use(.es256(key: .generate()))
        
        self.tokenRepository = TestRefreshTokenRepository(tokens: refreshtokens)
        self.userRepository = TestUserRepository(users: users)
        self.emailTokenRepository = TestEmailTokenRepository(tokens: emailTokens)
        self.passwordTokenRepository = TestPasswordTokenRepository(tokens: passwordTokens)
        self.contestRepository = TestContestRepository(contests: contests)

        app.repositories.use { _ in self.tokenRepository }
        app.repositories.use { _ in self.userRepository }
        app.repositories.use { _ in self.emailTokenRepository }
        app.repositories.use { _ in self.passwordTokenRepository }
        app.repositories.use { _ in self.contestRepository }

        app.queues.use(.test)
    }
}


