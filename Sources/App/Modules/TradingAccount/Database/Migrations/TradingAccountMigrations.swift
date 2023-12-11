import Vapor
import Fluent

enum TradingAccountMigrations {
    struct v1: AsyncMigration {
        func prepare(on database: Database) async throws {
            let provider = try await database.enum(TradingAccountModel.Provider.schema)
                .case(TradingAccountModel.Provider.webull.rawValue)
                .case(TradingAccountModel.Provider.etrade.rawValue)
                .create()

            try await database.schema(TradingAccountModel.schema)
                .id()
                .field(TradingAccountModel.FieldKeys.v1.userId, .uuid, .required)
                .foreignKey(
                    TradingAccountModel.FieldKeys.v1.userId,
                    references: UserAccountModel.schema, .id
                )
                .field(TradingAccountModel.FieldKeys.v1.provider, provider, .required)
                .create()
        }
        
        func revert(on database: Database) async throws {
            try await database.schema(TradingAccountModel.schema).delete()
            try await database.enum(TradingAccountModel.Provider.schema).delete()
        }
    }
}
