import Foundation

public enum Contest {
    
    public enum WinCondition: String, Codable {
        case highScore = "high_score"
        case target = "target"
    }
    
    public enum Visibility: String, Codable {
        case `public` = "public"
        case `private` = "private"
    }
    
    public enum FinancialInstrument: String, Codable {
        case stock, etf
    }
    
    public enum Market: String, Codable {
        case nasdaq, sp500, russell2000
    }

    public struct Create: Codable {
        public let name: String
        public let description: String
        public let winCondition: WinCondition
        public let targetProfitRatio: Double?
        public let visibility: Visibility
        public let minPlayers: Int
        public let maxPlayers: Int
        public let minUserLevel: Int
        public let instruments: [FinancialInstrument]
        public let markets: [Market]
        public let duration: TimeInterval
        public let startDate: Date
        public let endDate: Date
        public let marginAllowed: Bool
        public let minFund: Double
        public let tradesLimit: Int
        
        public init(
            name: String,
            description: String,
            winCondition: Contest.WinCondition,
            targetProfitRatio: Double? = nil,
            visibility: Contest.Visibility,
            minPlayers: Int,
            maxPlayers: Int,
            minUserLevel: Int,
            instruments: [Contest.FinancialInstrument],
            markets: [Contest.Market],
            duration: TimeInterval,
            startDate: Date,
            endDate: Date,
            marginAllowed: Bool,
            minFund: Double,
            tradesLimit: Int
        ) {
            self.name = name
            self.description = description
            self.winCondition = winCondition
            self.targetProfitRatio = targetProfitRatio
            self.visibility = visibility
            self.minPlayers = minPlayers
            self.maxPlayers = maxPlayers
            self.minUserLevel = minUserLevel
            self.instruments = instruments
            self.markets = markets
            self.duration = duration
            self.startDate = startDate
            self.endDate = endDate
            self.marginAllowed = marginAllowed
            self.minFund = minFund
            self.tradesLimit = tradesLimit
        }
    }

    public struct Detail: Codable {
        public let id: UUID
        public let name: String
        public let description: String
        public let creator: User.Account.Detail.Response
        public let participants: [User.Account.Detail.Response]
        public let winCondition: WinCondition
        public let targetProfitRatio: Double?
        public let visibility: Visibility
        public let minPlayers: Int
        public let maxPlayers: Int
        public let minUserLevel: Int
        public let instruments: [FinancialInstrument]
        public let markets: [Market]
        public let duration: TimeInterval
        public let startDate: Date
        public let endDate: Date
        public let marginAllowed: Bool
        public let minFund: Double
        public let tradesLimit: Int
        
        public init(
            id: UUID,
            name: String,
            description: String,
            creator: User.Account.Detail.Response,
            participants: [User.Account.Detail.Response],
            winCondition: Contest.WinCondition,
            targetProfitRatio: Double? = nil,
            visibility: Contest.Visibility,
            minPlayers: Int,
            maxPlayers: Int,
            minUserLevel: Int,
            instruments: [Contest.FinancialInstrument],
            markets: [Contest.Market],
            duration: TimeInterval,
            startDate: Date,
            endDate: Date,
            marginAllowed: Bool,
            minFund: Double,
            tradesLimit: Int
        ) {
            self.id = id
            self.name = name
            self.description = description
            self.creator = creator
            self.participants = participants
            self.winCondition = winCondition
            self.targetProfitRatio = targetProfitRatio
            self.visibility = visibility
            self.minPlayers = minPlayers
            self.maxPlayers = maxPlayers
            self.minUserLevel = minUserLevel
            self.instruments = instruments
            self.markets = markets
            self.duration = duration
            self.startDate = startDate
            self.endDate = endDate
            self.marginAllowed = marginAllowed
            self.minFund = minFund
            self.tradesLimit = tradesLimit
        }
    }
    
    public struct List: Codable {
        public let id: UUID
        public let name: String
        public let description: String
        public let creator: User.Account.Detail.Response
        public let participants: [User.Account.Detail.Response]
        public let winCondition: WinCondition
        public let targetProfitRatio: Double?
        public let visibility: Visibility
        public let minPlayers: Int
        public let maxPlayers: Int
        public let minUserLevel: Int
        public let instruments: [FinancialInstrument]
        public let markets: [Market]
        public let duration: TimeInterval
        public let startDate: Date
        public let endDate: Date
        public let marginAllowed: Bool
        public let minFund: Double
        public let tradesLimit: Int
        
        public init(
            id: UUID,
            name: String,
            description: String,
            creator: User.Account.Detail.Response,
            participants: [User.Account.Detail.Response],
            winCondition: Contest.WinCondition,
            targetProfitRatio: Double? = nil,
            visibility: Contest.Visibility,
            minPlayers: Int,
            maxPlayers: Int,
            minUserLevel: Int,
            instruments: [Contest.FinancialInstrument],
            markets: [Contest.Market],
            duration: TimeInterval,
            startDate: Date,
            endDate: Date,
            marginAllowed: Bool,
            minFund: Double,
            tradesLimit: Int
        ) {
            self.id = id
            self.name = name
            self.description = description
            self.creator = creator
            self.participants = participants
            self.winCondition = winCondition
            self.targetProfitRatio = targetProfitRatio
            self.visibility = visibility
            self.minPlayers = minPlayers
            self.maxPlayers = maxPlayers
            self.minUserLevel = minUserLevel
            self.instruments = instruments
            self.markets = markets
            self.duration = duration
            self.startDate = startDate
            self.endDate = endDate
            self.marginAllowed = marginAllowed
            self.minFund = minFund
            self.tradesLimit = tradesLimit
        }

    }
}

//
//
//{
//    "name" : "test",
//    "description" : "test descr",
//    "winCondition" : "highScore",
//    "visibility" : "public",
//    "minPlayers" : 2,
//    "maxPlayers" : 5,
//    "minUserLevel" : 0,
//    "instruments" : "stock",
//    "markets" : "sp500",
//    "duration" : 86400,
//    "startDate" : "2023-11-8T15:24:41Z",
//    "endDate" : "2023-11-15T15:24:41Z",
//    "marginAllowed" : true,
//    "minFund" : 2000,
//    "tradesLimit" : 0
//}
