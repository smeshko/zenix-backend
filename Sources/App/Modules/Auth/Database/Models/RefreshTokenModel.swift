import Vapor
import Framework
import Fluent

private let refreshTokenLifetime: TimeInterval = 7.days

final class RefreshTokenModel: TokenDatabaseModel {
    
    typealias Module = UserModule
    
    static var schema: String { "refresh_tokens" }
        
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: FieldKeys.v1.value)
    var value: String
    
    @Parent(key: FieldKeys.v1.userId)
    var user: UserAccountModel
    
    @Field(key: FieldKeys.v1.expiresAt)
    var expiresAt: Date
    
    @Field(key: FieldKeys.v1.issuedAt)
    var issuedAt: Date
    
    init() {}
    
    init(
        id: UUID? = nil,
        value: String,
        userID: UUID,
        expiresAt: Date = Date().addingTimeInterval(refreshTokenLifetime),
        issuedAt: Date = Date()
    ) {
        self.id = id
        self.value = value
        self.$user.id = userID
        self.expiresAt = expiresAt
        self.issuedAt = issuedAt
    }
}

extension RefreshTokenModel {
    struct FieldKeys {
        struct v1 {
            static var value: FieldKey { "value" }
            static var userId: FieldKey { "user_id" }
            static var expiresAt: FieldKey { "expires_at" }
            static var issuedAt: FieldKey { "issued_at" }
            
        }
    }
}
