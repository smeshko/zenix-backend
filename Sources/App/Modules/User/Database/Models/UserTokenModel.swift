import Fluent
import Vapor

final class UserTokenModel: DatabaseModelInterface {
    typealias Module = UserModule
    
    static var schema: String { "user_tokens" }
    
    struct FieldKeys {
        struct v1 {
            static var value: FieldKey { "value" }
            static var userId: FieldKey { "user_id" }
        }
    }
    
    @ID()
    var id: UUID?
    
    @Field(key: FieldKeys.v1.value)
    var value: String
    
    @Parent(key: FieldKeys.v1.userId)
    var user: UserAccountModel
    
    init() { }
    
    init(
        id: UUID? = nil,
        value: String,
        userId: UUID
    ) {
        self.id = id
        self.value = value
        self.$user.id = userId
    }

    static func generate(userId: UUID) -> UserTokenModel {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789="
        let tokenValue = String((0..<64).map { _ in letters.randomElement()! })

        return .init(
            value: tokenValue,
            userId: userId
        )
    }
}
