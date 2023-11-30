import Foundation

public extension User.Account {
    
    enum Detail {
        public struct Response: Codable {
            public let id: UUID
            public let email: String
            public let fullName: String
            public let status: Status
            public let level: Int
            public let isAdmin: Bool
            public let isEmailVerified: Bool

            public init(
                id: UUID,
                email: String,
                fullName: String,
                status: Status,
                level: Int,
                isAdmin: Bool,
                isEmailVerified: Bool
            ) {
                self.id = id
                self.email = email
                self.status = status
                self.fullName = fullName
                self.level = level
                self.isAdmin = isAdmin
                self.isEmailVerified = isEmailVerified
            }
        }
    }
    
    enum List {
        public struct Response: Codable {
            public let id: UUID
            public let email: String
            public let password: String
            public let fullName: String
            public let status: Status
            public let level: Int

            public init(
                id: UUID,
                email: String,
                password: String,
                fullName: String,
                status: Status,
                level: Int
            ) {
                self.id = id
                self.email = email
                self.password = password
                self.fullName = fullName
                self.status = status
                self.level = level
            }
        }
    }
        
    enum Status: String, Codable {
        case openForChallenge = "open_for_challenge"
        case notAccepting = "not_accepting"
    }
}
