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
            fullName: model.fullName,
            status: model.challengeStatus.local,
            level: model.level
        )
    }
}

extension User.Account.Patch.Response: Content {
    init(from model: UserAccountModel) throws {
        try self.init(
            id: model.requireID(),
            email: model.email,
            fullName: model.fullName,
            status: model.challengeStatus.local,
            level: model.level,
            isAdmin: model.isAdmin,
            isEmailVerified: model.isEmailVerified
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

extension User.Account.Status {
    var db: UserAccountModel.ChallengeStatus {
        switch self {
        case .notAccepting: .notAccepting
        case .openForChallenge: .openForChallenge
        }
    }
}
