@testable import App
import Fluent
import FluentSQLiteDriver
import XCTVapor

class TestWorld {
    let app: Application
    
    // Repositories
    private var tokenRepository: TestRefreshTokenRepository
    private var userRepository: TestUserRepository
    private var emailTokenRepository: TestEmailTokenRepository
    private var passwordTokenRepository: TestPasswordTokenRepository
    private var contestRepository: TestContestRepository
    private var contestParticipantsRepository: TestContestParticipantsRepository
    private var tradingAccountRepository: TestTradingAccountRepository
    
    init(app: Application) throws {
        self.app = app
        
        try app.jwt.signers.use(.es256(key: .generate()))
        
        self.tokenRepository = .init()
        self.userRepository = .init()
        self.emailTokenRepository = .init()
        self.passwordTokenRepository = .init()
        self.contestRepository = .init()
        self.contestParticipantsRepository = .init()
        self.tradingAccountRepository = .init()
        
        app.repositories.use { _ in self.tokenRepository }
        app.repositories.use { _ in self.userRepository }
        app.repositories.use { _ in self.emailTokenRepository }
        app.repositories.use { _ in self.passwordTokenRepository }
        app.repositories.use { _ in self.contestRepository }
        app.repositories.use { _ in self.contestParticipantsRepository }
        app.repositories.use { _ in self.tradingAccountRepository }
        
        app.dataClients.use { _ in .test }
    }
}

extension MarketClient {
    static var test: MarketClient {
        .init { .open }
    }
}
