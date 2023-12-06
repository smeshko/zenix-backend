import Entities
import Vapor

extension Contest.Details.Response: Content {
    init(
        from model: ContestModel,
        creator: User.Account.List.Response,
        participants: [User.Account.List.Response]
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
            startDate: model.startDate,
            endDate: model.endDate,
            marginAllowed: model.marginAllowed,
            minFund: model.minFund,
            tradesLimit: model.tradesLimit,
            status: model.status.local
        )
    }
}
