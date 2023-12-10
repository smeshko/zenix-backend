import Vapor
import Fluent

enum TradingAccountMigrations {
    struct v1: AsyncMigration {
        func prepare(on database: Database) async throws {
            
        }
        
        func revert(on database: Database) async throws {
            
        }
    }
}
