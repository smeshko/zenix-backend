import Vapor
import Fluent

final class ContestParticipantModel: Model {
    static let schema = "contest_participants"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: FieldKeys.v1.contestId)
    var contest: ContestModel

    @Parent(key: FieldKeys.v1.userId)
    var user: UserAccountModel

    @Timestamp(key: FieldKeys.v1.createdAt, on: .create)
    var createdAt: Date?
    
    @Enum(key: FieldKeys.v1.role)
    var role: Role

    init() { }

    init(
        id: UUID? = nil,
        contest: ContestModel,
        user: UserAccountModel,
        role: Role,
        dateRegistered: Date
    ) throws {
        self.id = id
        self.$contest.id = try contest.requireID()
        self.$user.id = try user.requireID()
        self.role = role
    }
}

extension ContestParticipantModel {
    struct FieldKeys {
        struct v1 {
            static var contestId: FieldKey { "contest_id" }
            static var userId: FieldKey { "user_id" }
            static var createdAt: FieldKey { "created_at" }
            static var role: FieldKey { "role" }
        }
    }
}

extension ContestParticipantModel {
    enum Role: String, Codable {
        case creator
        case participant
        
        static var schema: String {
            "role_enum"
        }
    }
}
