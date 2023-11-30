import Entities
import Vapor

extension User.Account.Detail.Response: Content {
    init(from model: UserAccountModel) throws {
        self.init(
            id: try model.requireID(),
            email: model.email,
            fullName: model.fullName,
            status: model.challengeStatus.local,
            level: model.level,
            isAdmin: model.isAdmin,
            isEmailVerified: model.isEmailVerified
        )
    }
}

extension User.Account.List.Response: Content {
    init(from model: UserAccountModel) throws {
        self.init(
            id: try model.requireID(),
            email: model.email,
            password: model.password,
            fullName: model.fullName,
            status: model.challengeStatus.local,
            level: model.level
        )
    }
}

extension UserAccountModel.ChallengeStatus {
    var local: User.Account.Status {
        switch self {
        case .notAccepting: .notAccepting
        case .openForChallenge: .openForChallenge
        }
    }
}
