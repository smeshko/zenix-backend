import Vapor
import Fluent

enum ContestMigrations {
    struct v1: AsyncMigration {
        func prepare(on database: Database) async throws {
            let winCondition = try await database.enum(ContestModel.WinCondition.schema)
                .case(ContestModel.WinCondition.highScore.rawValue)
                .case(ContestModel.WinCondition.target.rawValue)
                .create()

            let visibility = try await database.enum(ContestModel.Visibility.schema)
                .case(ContestModel.Visibility.private.rawValue)
                .case(ContestModel.Visibility.public.rawValue)
                .create()

            try await database.schema(ContestModel.schema)
                .id()
                .field(ContestModel.FieldKeys.v1.creator, .uuid, .required)
                .foreignKey(
                    ContestModel.FieldKeys.v1.creator,
                    references: UserAccountModel.schema, .id
                )
                .field(ContestModel.FieldKeys.v1.name, .string, .required)
                .field(ContestModel.FieldKeys.v1.description, .string, .required)
                .field(ContestModel.FieldKeys.v1.winCondition, winCondition, .required)
                .field(ContestModel.FieldKeys.v1.targetProfitRatio, .double)
                .field(ContestModel.FieldKeys.v1.visibility, visibility, .required)
                .field(ContestModel.FieldKeys.v1.minPlayers, .int, .required)
                .field(ContestModel.FieldKeys.v1.maxPlayers, .int, .required)
                .field(ContestModel.FieldKeys.v1.minUserLevel, .int, .required)
                .field(ContestModel.FieldKeys.v1.instruments, .array(of: .string), .required)
                .field(ContestModel.FieldKeys.v1.markets, .array(of: .string), .required)
                .field(ContestModel.FieldKeys.v1.startDate, .datetime, .required)
                .field(ContestModel.FieldKeys.v1.endDate, .datetime, .required)
                .field(ContestModel.FieldKeys.v1.marginAllowed, .bool, .required)
                .field(ContestModel.FieldKeys.v1.minFund, .double, .required)
                .field(ContestModel.FieldKeys.v1.tradesLimit, .int, .required)
                .create()
            
            let role = try await database.enum(ContestParticipantModel.Role.schema)
                .case(ContestParticipantModel.Role.creator.rawValue)
                .case(ContestParticipantModel.Role.participant.rawValue)
                .create()

            try await database.schema(ContestParticipantModel.schema)
                .id()
                .field(
                    ContestParticipantModel.FieldKeys.v1.userId, .uuid, .required,
                    .references(UserAccountModel.schema, "id", onDelete: .cascade)
                )
                .field(
                    ContestParticipantModel.FieldKeys.v1.contestId, .uuid, .required,
                    .references(ContestModel.schema, "id", onDelete: .cascade)
                )
                .field(ContestParticipantModel.FieldKeys.v1.role, role, .required)
                .field(ContestParticipantModel.FieldKeys.v1.createdAt, .datetime, .required)
                .create()

        }
        
        func revert(on database: Database) async throws {
            try await database.schema(ContestParticipantModel.schema).delete()
            try await database.enum(ContestParticipantModel.Role.schema).delete()
            try await database.schema(ContestModel.schema).delete()
            try await database.enum(ContestModel.WinCondition.schema).delete()
            try await database.enum(ContestModel.Visibility.schema).delete()
        }
    }
    
    struct v2: AsyncMigration {
        func prepare(on database: Database) async throws {
            let status = try await database.enum(ContestModel.Status.schema)
                .case(ContestModel.Status.draft.rawValue)
                .case(ContestModel.Status.ready.rawValue)
                .case(ContestModel.Status.running.rawValue)
                .case(ContestModel.Status.archived.rawValue)
                .create()

            try await database.schema(ContestModel.schema)
                .field(ContestModel.FieldKeys.v2.status, status, .required, .sql(.default("ready")))
                .update()
            
            let _ = try await database.enum(ContestParticipantModel.Role.schema)
                .case(ContestParticipantModel.Role.applicant.rawValue)
                .update()

            try await database.schema(ContestParticipantModel.schema)
                .field(ContestParticipantModel.FieldKeys.v2.accountNumber, .string)
                .field(ContestParticipantModel.FieldKeys.v2.rank, .int16, .required, .sql(.default(0)))
                .update()
        }
        
        func revert(on database: Database) async throws {
            try await database.schema(ContestModel.schema)
                .deleteField(ContestModel.FieldKeys.v2.status)
                .update()
            try await database.enum(ContestModel.Status.schema).delete()
            
            _ = try await database.enum(ContestParticipantModel.Role.schema)
                .deleteCase(ContestParticipantModel.Role.applicant.rawValue)
                .update()
            
            try await database.schema(ContestParticipantModel.schema)
                .deleteField(ContestParticipantModel.FieldKeys.v2.accountNumber)
                .deleteField(ContestParticipantModel.FieldKeys.v2.rank)
                .update()
        }
    }
}
