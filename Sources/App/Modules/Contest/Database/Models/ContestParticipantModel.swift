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
    
    @OptionalField(key: FieldKeys.v2.accountNumber)
    var accountNumber: String?
    
    @Field(key: FieldKeys.v2.rank)
    var rank: Int

    init() { }

    init(
        id: UUID? = nil,
        contest: ContestModel,
        user: UserAccountModel,
        role: Role = .participant,
        accountNumber: String? = nil,
        rank: Int = 0
    ) throws {
        self.id = id
        self.$contest.id = try contest.requireID()
        self.$user.id = try user.requireID()
        self.role = role
        self.accountNumber = accountNumber
        self.rank = rank
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
        
        struct v2 {
            static var accountNumber: FieldKey { "account_number" }
            static var rank: FieldKey { "rank" }
        }
    }
}

extension ContestParticipantModel {
    enum Role: String, Codable {
        case creator
        case participant
        case applicant
        
        static var schema: String {
            "role_enum"
        }
    }
}
