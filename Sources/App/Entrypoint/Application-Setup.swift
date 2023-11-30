import Vapor
import Framework
import FluentPostgresDriver
import JWT
import Queues
import QueuesRedisDriver

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
            let jwksFilePath = directory.workingDirectory + (Environment.get("JWKS_KEYPAIR_FILE") ?? "keypair.jwks")
             guard
                 let jwks = FileManager.default.contents(atPath: jwksFilePath),
                 let jwksString = String(data: jwks, encoding: .utf8)
                 else {
                     fatalError("Failed to load JWKS Keypair file at: \(jwksFilePath)")
             }
             try jwt.signers.use(jwksJSON: jwksString)
        }
    }
    
    func setupServices() {
        randomGenerators.use(.random)
        repositories.use(.database)
    }
}
