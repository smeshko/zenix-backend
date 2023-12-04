import Entities

extension Contest.WinCondition {
    var db: ContestModel.WinCondition {
        switch self {
        case .highScore: return .highScore
        case .target: return .target
        }
    }
}

extension Contest.Visibility {
    var db: ContestModel.Visibility {
        switch self {
        case .public: return .public
        case .private: return .private
        }
    }
}

extension ContestModel.WinCondition {
    var local: Contest.WinCondition {
        switch self {
        case .highScore: return .highScore
        case .target: return .target
        }
    }
}

extension ContestModel.Visibility {
    var local: Contest.Visibility {
        switch self {
        case .public: return .public
        case .private: return .private
        }
    }
}
