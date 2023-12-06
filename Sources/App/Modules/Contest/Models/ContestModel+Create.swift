import Common
import Entities
import Vapor

extension ContestModel {
    convenience init(
        from content: Contest.Create.Request,
        creatorID: UserAccountModel.IDValue
    ) {
        self.init(
            creatorID: creatorID,
            name: content.name,
            description: content.description,
            winCondition: content.winCondition.db,
            targetProfitRatio: content.targetProfitRatio,
            visibility: content.visibility.db,
            minPlayers: content.minPlayers,
            maxPlayers: content.maxPlayers,
            instruments: content.instruments.map(\.rawValue),
            markets: content.markets.map(\.rawValue),
            startDate: content.startDate,
            endDate: content.startDate + content.duration.time,
            minFund: content.minFund
        )
    }
}

extension Contest.Create.Response: Content {
    init(
        from model: ContestModel,
        creator: User.Account.List.Response
    ) throws {
        self.init(
            id: try model.requireID(),
            name: model.name,
            description: model.description,
            creator: creator,
            participants: [],
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
            startDate: model.startDate,
            endDate: model.endDate,
            marginAllowed: model.marginAllowed,
            minFund: model.minFund,
            tradesLimit: model.tradesLimit
        )
    }
}

private extension Contest.Duration {
    var time: TimeInterval {
        switch self {
        case .day: 24.hours
        case .week: 7.days
        case .month: 30.days
        case .quarter: 90.days
        }
    }
}
