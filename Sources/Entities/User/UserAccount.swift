import Foundation

public extension User.Account {
    
    struct Login: Codable {
        public let email: String
        public let password: String
        
        public init(
            email: String,
            password: String
        ) {
            self.email = email
            self.password = password
        }
    }
    
    struct List: Codable {
        public let id: UUID
        public let email: String
        public let status: Status
        public let level: Int
        
        public init(
            id: UUID,
            email: String,
            status: Status,
            level: Int
        ) {
            self.id = id
            self.email = email
            self.status = status
            self.level = level
        }
    }
    
    struct Detail: Codable {
        public let id: UUID
        public let email: String
        public let status: Status
        public let level: Int

        public init(
            id: UUID,
            email: String,
            status: Status,
            level: Int
        ) {
            self.id = id
            self.email = email
            self.status = status
            self.level = level
        }
    }
    
    struct Create: Codable {
        public let email: String
        public let password: String
        
        public init(
            email: String,
            password: String
        ) {
            self.email = email
            self.password = password
        }
    }
    
    struct Update: Codable {
        public let email: String
        public let password: String?
        
        public init(
            email: String,
            password: String
        ) {
            self.email = email
            self.password = password
        }
    }
    
    struct Patch: Codable {
        public let email: String?
        public let password: String?
        
        public init(
            email: String?,
            password: String?
        ) {
            self.email = email
            self.password = password
        }
    }
    
    enum Status: String, Codable {
        case openForChallenge = "open_for_challenge"
        case notAccepting = "not_accepting"
    }
}
