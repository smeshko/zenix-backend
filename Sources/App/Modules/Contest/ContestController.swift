import Vapor
import Fluent
import Entities

extension Contest.Create: Content {}
extension Contest.Detail: Content {}
extension Contest.List: Content {}

struct ContestController {
    func create(_ req: Request) async throws -> Contest.Detail {
        guard let user = req.auth.get(AuthenticatedUser.self),
              let userModel = try await UserAccountModel.find(user.id, on: req.db) else {
            throw Abort(.unauthorized)
        }
        let contest = try req.content.decode(Contest.Create.self)
        let contestModel = try ContestModel(content: contest, user: userModel)
        
        try await contestModel.save(on: req.db)
        try await contestModel.$participants.attach(userModel, on: req.db) { pivot in
            pivot.role = .creator
        }
        
        return try .init(
            model: contestModel,
            participants: [],
            creator: .init(
                id: try userModel.requireID(),
                email: userModel.email,
                status: userModel.status.local,
                level: userModel.level
            )
        )
    }

    func delete(_ req: Request) async throws -> HTTPStatus {
        guard let user = req.auth.get(AuthenticatedUser.self),
              let userModel = try await UserAccountModel.find(user.id, on: req.db) else {
            throw Abort(.unauthorized)
        }
        
        let contestID = try req.parameters.require("contestID", as: UUID.self)

        guard let contest = try await ContestModel.find(contestID, on: req.db) else {
            throw Abort(.notFound)
        }
        let creator = try await contest.$creator.get(on: req.db)
        guard creator.id == userModel.id else {
            throw Abort(.unauthorized)
        }

        try await contest.delete(on: req.db)
        
        return .ok
    }

    func join(_ req: Request) async throws -> Contest.Detail {
        guard let user = req.auth.get(AuthenticatedUser.self),
              let userModel = try await UserAccountModel.find(user.id, on: req.db) else {
            throw Abort(.unauthorized)
        }
        
        let contestID = try req.parameters.require("contestID", as: UUID.self)

        guard let contest = try await ContestModel.find(contestID, on: req.db) else {
            throw Abort(.notFound)
        }
        
        let participants = try await contest.$participants.get(on: req.db)
        
        guard !participants.contains(where: { $0.id == userModel.id }) else {
            throw .userAlreadyParticipantInContest()
        }
        
        try await userModel.$contests.attach(contest, on: req.db) { pivot in
            pivot.role = .participant
        }
        
        let creator = try await User.Account.Detail(model: contest.$creator.get(on: req.db))
        let contestParticipants = try await ContestParticipantModel.query(on: req.db)
            .all()
            .map(\.$user.id)
            .asyncMap {
                try await UserAccountModel.find($0, on: req.db)
            }
            .map(User.Account.Detail.init(model:))
                
        
        return try .init(
            model: contest,
            participants: contestParticipants,
            creator: creator
        )
    }
    
    func list(_ req: Request) async throws -> [Contest.List] {
        try await ContestModel.query(on: req.db)
            .all()
            .asyncMap {
                try await Contest.List.init(model: $0, db: req.db)
            }
    }

    func leave(_ req: Request) async throws -> HTTPStatus {
        guard let user = req.auth.get(AuthenticatedUser.self),
              let userModel = try await UserAccountModel.find(user.id, on: req.db) else {
            throw Abort(.unauthorized)
        }
        
        let contestID = try req.parameters.require("contestID", as: UUID.self)

        guard let contest = try await ContestModel.find(contestID, on: req.db) else {
            throw Abort(.notFound)
        }
        
        let participants = try await contest.$participants.get(on: req.db)
        let creator = try await contest.$creator.get(on: req.db)

        guard participants.contains(where: { $0.id == userModel.id }) else {
            throw .userNotInContest()
        }
        guard creator.id != userModel.id else {
            throw .creatorCannotLeaveContest()
        }
        
        try await contest.$participants.detach(userModel, on: req.db)
        
        return .ok
    }
}

private extension ContestModel {
    convenience init(content: Contest.Create, user: UserAccountModel) throws {
        self.init(
            creatorID: try user.requireID(),
            name: content.name,
            description: content.description,
            winCondition: content.winCondition.modelEnum,
            targetProfitRatio: content.targetProfitRatio,
            visibility: content.visibility.modelEnum,
            minPlayers: content.minPlayers,
            maxPlayers: content.maxPlayers,
            minUserLevel: content.minUserLevel,
            instruments: content.instruments.map(\.rawValue),
            markets: content.markets.map(\.rawValue),
            duration: content.duration,
            startDate: content.startDate,
            endDate: content.endDate,
            marginAllowed: content.marginAllowed,
            minFund: content.minFund,
            tradesLimit: content.tradesLimit
        )
    }
}

private extension Contest.WinCondition {
    var modelEnum: ContestModel.WinCondition {
        switch self {
        case .highScore: return .highScore
        case .target: return .target
        }
    }
}

private extension Contest.Visibility {
    var modelEnum: ContestModel.Visibility {
        switch self {
        case .public: return .public
        case .private: return .private
        }
    }
}

private extension ContestModel.WinCondition {
    var local: Contest.WinCondition {
        switch self {
        case .highScore: return .highScore
        case .target: return .target
        }
    }
}

private extension ContestModel.Visibility {
    var local: Contest.Visibility {
        switch self {
        case .public: return .public
        case .private: return .private
        }
    }
}

private extension Contest.Detail {
    init(
        model: ContestModel,
        participants: [User.Account.Detail],
        creator: User.Account.Detail
    ) throws {
        self.init(
            id: try model.requireID(),
            name: model.name,
            description: model.description,
            creator: creator,
            participants: participants,
            winCondition: model.winCondition.local,
            targetProfitRatio: model.targetProfitRatio,
            visibility: model.visibility.local,
            minPlayers: model.minPlayers,
            maxPlayers: model.maxPlayers,
            minUserLevel: model.minUserLevel,
            instruments: model.instruments.map {
                Contest.FinancialInstrument(rawValue: $0) ?? .stock
            },
            markets: model.markets.map {
                Contest.Market(rawValue: $0) ?? .sp500
            },
            duration: model.duration,
            startDate: model.startDate,
            endDate: model.endDate,
            marginAllowed: model.marginAllowed,
            minFund: model.minFund,
            tradesLimit: model.tradesLimit
        )
    }
}

private extension Contest.List {
    init(
        model: ContestModel,
        db: Database
    ) async throws {
        await self.init(
            id: try model.requireID(),
            name: model.name,
            description: model.description,
            creator: try User.Account.Detail(model: model.$creator.get(on: db)),
            participants: try (model.$participants.get(on: db)).map(User.Account.Detail.init(model:)),
            winCondition: model.winCondition.local,
            targetProfitRatio: model.targetProfitRatio,
            visibility: model.visibility.local,
            minPlayers: model.minPlayers,
            maxPlayers: model.maxPlayers,
            minUserLevel: model.minUserLevel,
            instruments: model.instruments.map {
                Contest.FinancialInstrument(rawValue: $0) ?? .stock
            },
            markets: model.markets.map {
                Contest.Market(rawValue: $0) ?? .sp500
            },
            duration: model.duration,
            startDate: model.startDate,
            endDate: model.endDate,
            marginAllowed: model.marginAllowed,
            minFund: model.minFund,
            tradesLimit: model.tradesLimit
        )
    }
}

private extension User.Account.Detail {
    init(model: UserAccountModel?) throws {
        guard let model else {
            throw Abort(.badRequest)
        }
        self.init(
            id: try model.requireID(),
            email: model.email,
            status: model.status.local,
            level: model.level
        )
    }
}
