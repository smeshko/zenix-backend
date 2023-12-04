import Entities
import Vapor

extension Contest.List.Response: Content {
    init(
        from model: ContestModel,
        participants: Int
    ) throws {
        self.init(
            id: try model.requireID(),
            name: model.name,
            description: model.description,
            winCondition: model.winCondition.local,
            targetProfitRatio: model.targetProfitRatio,
            visibility: model.visibility.local,
            currentPlayers: participants,
            maxPlayers: model.maxPlayers,
            minUserLevel: model.minUserLevel,
            instruments: model.instruments.map {
                Contest.FinancialInstrument(rawValue: $0) ?? .stock
            },
            startDate: model.startDate,
            endDate: model.endDate,
            minFund: model.minFund
        )
    }
}
