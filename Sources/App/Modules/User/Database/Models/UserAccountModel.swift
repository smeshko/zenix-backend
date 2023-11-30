import Framework
import Vapor
import Fluent

final class UserAccountModel: DatabaseModelInterface {
    typealias Module = UserModule
    static var schema: String { "users" }
    @ID()
    var id: UUID?
    
    @Field(key: FieldKeys.v1.email)
    var email: String
    
    @Field(key: FieldKeys.v1.password)
    var password: String
    
    @Field(key: FieldKeys.v1.fullName)
    var fullName: String
    
    @Field(key: FieldKeys.v1.isAdmin)
    var isAdmin: Bool
    
    @Field(key: FieldKeys.v1.isEmailVerified)
    var isEmailVerified: Bool

    @Enum(key: FieldKeys.v1.status)
    var challengeStatus: ChallengeStatus
    
    @Field(key: FieldKeys.v1.level)
    var level: Int
    
    @Siblings(through: ContestParticipantModel.self, from: \.$user, to: \.$contest)
    var contests: [ContestModel]

    init() { }
    
    init(
        id: UUID? = nil,
        email: String,
        password: String,
        fullName: String,
        isAdmin: Bool = false,
        isEmailVerified: Bool = false,
        status: ChallengeStatus = .notAccepting,
        level: Int = 0
    ) {
        self.id = id
        self.email = email
        self.fullName = fullName
        self.isAdmin = isAdmin
        self.isEmailVerified = isEmailVerified
        self.password = password
        self.challengeStatus = status
        self.level = level
    }
}

extension UserAccountModel {
    enum ChallengeStatus: String, Codable {
        case openForChallenge = "open_for_challenge"
        case notAccepting = "not_accepting"
        
        static var schema: String {
            "challenge_status_enum"
        }
    }
}

extension UserAccountModel {
    struct FieldKeys {
        struct v1 {
            static var email: FieldKey { "email" }
            static var password: FieldKey { "password" }
            static var status: FieldKey { "challenge_status" }
            static var level: FieldKey { "level" }
            static var isAdmin: FieldKey { "is_admin" }
            static var isEmailVerified: FieldKey { "is_email_verified" }
            static var fullName: FieldKey { "full_name" }
        }
    }
}
