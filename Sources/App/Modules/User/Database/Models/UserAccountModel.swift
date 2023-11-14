import Framework
import Vapor
import Fluent

final class UserAccountModel: DatabaseModelInterface {
    typealias Module = UserModule
    
    @ID()
    var id: UUID?
    
    @Field(key: FieldKeys.v1.email)
    var email: String
    
    @Field(key: FieldKeys.v1.password)
    var password: String
    
    @Enum(key: FieldKeys.v2.status)
    var status: Status
    
    @Field(key: FieldKeys.v2.level)
    var level: Int
    
    @Siblings(through: ContestParticipantModel.self, from: \.$user, to: \.$contest)
    var contests: [ContestModel]

    init() { }
    
    init(
        id: UUID? = nil,
        email: String,
        password: String,
        status: Status,
        level: Int
    ) {
        self.id = id
        self.email = email
        self.password = password
        self.status = status
        self.level = level
    }
}

extension UserAccountModel {
    enum Status: String, Codable {
        case openForChallenge = "open_for_challenge"
        case notAccepting = "not_accepting"
        
        static var schema: String {
            "status_enum"
        }
    }
}

extension UserAccountModel {
    struct FieldKeys {
        struct v1 {
            static var email: FieldKey { "email" }
            static var password: FieldKey { "password" }
        }
        
        struct v2 {
            static var status: FieldKey { "status" }
            static var level: FieldKey { "level" }
        }
    }
}
