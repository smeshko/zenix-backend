import FluentPostgresDriver
import FluentSQLiteDriver
import JWT
import Vapor

private extension String {
    var bytes: [UInt8] { .init(self.utf8) }
}

private extension JWKIdentifier {
    static let `public` = JWKIdentifier(string: "public")
    static let `private` = JWKIdentifier(string: "private")
}

extension Application {
    
    func setupMiddleware() {
        middleware = .init()
        middleware.use(ErrorMiddleware.custom(environment: environment))
        middleware.use(FileMiddleware(publicDirectory: directory.publicDirectory))
    }
    
    func setupModules() throws {
        var modules: [ModuleInterface] = [
            RootModule(),
            UserModule(),
            AuthModule(),
            TradingAccountModule(),
            ContestModule(),
            FrontendModule()
        ]
        
        if environment != .testing {
            modules.append(MetricsModule())
        }
        
        for module in modules {
            try module.boot(self)
        }
        
        for module in modules {
            try module.setUp(self)
        }
    }
    
    func setupDB() throws {
        try databases.use(.postgres(url: Environment.databaseURL), as: .psql)
    }
    
    func setupJWT() throws {
        if environment != .testing {
            jwt.signers.use(.hs256(key: Environment.jwtKey))
        }
    }
    
    func setupServices() {
        randomGenerators.use(.random)
        repositories.use(.database)
    }
}
