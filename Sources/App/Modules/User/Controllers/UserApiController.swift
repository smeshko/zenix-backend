import Vapor

extension User.Token.Detail: Content {}

struct UserApiController {
    
    func signIn(_ req: Request) async throws -> User.Token.Detail {
        guard let user = req.auth.get(AuthenticatedUser.self) else {
            throw Abort(.unauthorized)
        }

        let token = UserTokenModel.generate(userId: user.id)
        try await token.create(on: req.db)

        let account = User.Account.Detail(
            id: user.id,
            email: user.email
        )
        return .init(
            id: token.id!,
            value: token.value,
            user: account
        )
    }
    
    func signUp(_ req: Request) async throws -> User.Token.Detail {
        try User.Account.Create.validate(content: req)
        let userCreate = try req.content.decode(User.Account.Create.self)
        let userModel =  UserAccountModel(
            email: userCreate.email,
            password: try Bcrypt.hash(userCreate.password)
        )
        
        try await userModel.save(on: req.db)
        
        let token = UserTokenModel.generate(userId: userModel.id!)
        try await token.create(on: req.db)
        
        let account = User.Account.Detail(
            id: userModel.id!,
            email: userModel.email
        )
        
        return .init(
            id: token.id!,
            value: token.value,
            user: account
        )
    }
}

extension User.Account.Create: Validatable {
    public static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: .count(8...))
    }
}
