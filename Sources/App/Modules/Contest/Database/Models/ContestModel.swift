import Fluent
import Vapor

final class ContestModel: DatabaseModelInterface {
    typealias Module = ContestModule
    
    static var schema: String { "contests" }
        
    @ID()
    var id: UUID?
    
    @Parent(key: FieldKeys.v1.creator)
    var creator: UserAccountModel
    
    @Siblings(through: ContestParticipantModel.self, from: \.$contest, to: \.$user)
    var participants: [UserAccountModel]

    @Field(key: FieldKeys.v1.name)
    var name: String
    
    @Field(key: FieldKeys.v1.description)
    var description: String
    
    @Enum(key: FieldKeys.v1.winCondition)
    var winCondition: WinCondition
    
    @OptionalField(key: FieldKeys.v1.targetProfitRatio)
    var targetProfitRatio: Double?
    
    @Enum(key: FieldKeys.v1.visibility)
    var visibility: Visibility
    
    @Field(key: FieldKeys.v1.minPlayers)
    var minPlayers: Int
    
    @Field(key: FieldKeys.v1.maxPlayers)
    var maxPlayers: Int
    
    @Field(key: FieldKeys.v1.minUserLevel)
    var minUserLevel: Int
    
    @Field(key: FieldKeys.v1.instruments)
    var instruments: [String]
    
    @Field(key: FieldKeys.v1.markets)
    var markets: [String]
    
    @Field(key: FieldKeys.v1.startDate)
    var startDate: Date
    
    @Field(key: FieldKeys.v1.endDate)
    var endDate: Date
    
    @Field(key: FieldKeys.v1.marginAllowed)
    var marginAllowed: Bool
    
    @Field(key: FieldKeys.v1.minFund)
    var minFund: Double
    
    @Field(key: FieldKeys.v1.tradesLimit)
    var tradesLimit: Int
    
    @Enum(key: FieldKeys.v2.status)
    var status: Status

    init() {}

    init(
        id: UUID? = nil,
        creatorID: UserAccountModel.IDValue,
        name: String,
        description: String,
        winCondition: ContestModel.WinCondition,
        targetProfitRatio: Double? = nil,
        visibility: ContestModel.Visibility,
        minPlayers: Int,
        maxPlayers: Int,
        minUserLevel: Int = 0,
        instruments: [String],
        markets: [String],
        startDate: Date,
        endDate: Date,
        marginAllowed: Bool = true,
        minFund: Double,
        tradesLimit: Int = 0,
        status: Status = .draft
    ) {
        self.id = id
        self.$creator.id = creatorID
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
        self.startDate = startDate
        self.endDate = endDate
        self.marginAllowed = marginAllowed
        self.minFund = minFund
        self.tradesLimit = tradesLimit
        self.status = status
    }
}

extension ContestModel {
    
    enum WinCondition: String, Codable {
        case highScore = "high_score"
        case target = "target"
        
        static var schema: String {
            "win_condition_enum"
        }
    }
    
    enum Visibility: String, Codable {
        case `public` = "public"
        case `private` = "private"
        
        static var schema: String {
            "visibility_enum"
        }
    }
    
    enum Status: String, Codable {
        case draft, ready, running, archived
        
        static var schema: String {
            "contest_status_enum"
        }
    }
}

extension ContestModel {
    struct FieldKeys {
        struct v1 {
            static var creator: FieldKey { "user_id" }
            static var contestants: FieldKey { "contenstants" }
            static var name: FieldKey { "name" }
            static var description: FieldKey { "description" }
            static var winCondition: FieldKey { "win_condition" }
            static var targetProfitRatio: FieldKey { "target_profit_ratio" }
            static var visibility: FieldKey { "visibility" }
            static var minPlayers: FieldKey { "min_players" }
            static var maxPlayers: FieldKey { "max_players" }
            static var minUserLevel: FieldKey { "min_user_level" }
            static var instruments: FieldKey { "instruments" }
            static var markets: FieldKey { "markets" }
            static var duration: FieldKey { "duration" }
            static var startDate: FieldKey { "start_date" }
            static var endDate: FieldKey { "end_date" }
            static var marginAllowed: FieldKey { "margin_allowed" }
            static var minFund: FieldKey { "min_fund" }
            static var tradesLimit: FieldKey { "trades_limit" }
        }
        
        struct v2 {
            static var status: FieldKey { "status" }
        }
    }
}
