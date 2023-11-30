import Vapor
import Fluent

enum UserMigrations {
    
    struct v1: AsyncMigration {
        
        func prepare(on db: Database) async throws {
            let status = try await db.enum(UserAccountModel.ChallengeStatus.schema)
                .case(UserAccountModel.ChallengeStatus.notAccepting.rawValue)
                .case(UserAccountModel.ChallengeStatus.openForChallenge.rawValue)
                .create()

            try await db.schema(UserAccountModel.schema)
                .id()
                .field(UserAccountModel.FieldKeys.v1.email, .string, .required)
                .field(UserAccountModel.FieldKeys.v1.password, .string, .required)
                .field(UserAccountModel.FieldKeys.v1.fullName, .string, .required)
                .field(UserAccountModel.FieldKeys.v1.isAdmin, .bool, .required)
                .field(UserAccountModel.FieldKeys.v1.isEmailVerified, .bool, .required)
                .field(UserAccountModel.FieldKeys.v1.level, .int16, .required)
                .field(
                    UserAccountModel.FieldKeys.v1.status,
                    status, .required,
                    .sql(.default(UserAccountModel.ChallengeStatus.notAccepting.rawValue))
                )
                .unique(on: UserAccountModel.FieldKeys.v1.email)
                .create()
        }

        func revert(on db: Database) async throws  {
            try await db.schema(UserAccountModel.schema).delete()
            try await db.enum(UserAccountModel.ChallengeStatus.schema).delete()
        }
    }
    
    struct seed: AsyncMigration {
        
        func prepare(on db: Database) async throws {
            let email = "root@localhost.com"
            let password = "ChangeMe1"
            let user = UserAccountModel(
                email: email,
                password: try Bcrypt.hash(password),
                fullName: "John Doe",
                isAdmin: true,
                isEmailVerified: true,
                status: .notAccepting,
                level: 0
            )
            try await user.create(on: db)
        }

        func revert(on db: Database) async throws {
            try await UserAccountModel.query(on: db).delete()
        }
    }
}
