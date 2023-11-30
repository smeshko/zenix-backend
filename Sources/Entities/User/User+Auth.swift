import Foundation

public extension User.Auth {
    enum Login {
        public struct Request: Codable {
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
        
        public struct Response: Codable {
            public let token: User.Token.Refresh.Response
            public let user: User.Account.Detail.Response
            
            public init(
                token: User.Token.Refresh.Response,
                user: User.Account.Detail.Response
            ) {
                self.token = token
                self.user = user
            }
        }
    }
    
    enum Create {
        public struct Request: Codable {
            public let email: String
            public let password: String
            public let fullName: String
            
            public init(
                email: String,
                password: String,
                fullName: String
            ) {
                self.email = email
                self.password = password
                self.fullName = fullName
            }
        }
        
        public struct Response: Codable {
            public let token: User.Token.Refresh.Response
            public let user: User.Account.Detail.Response

            public init(
                token: User.Token.Refresh.Response,
                user: User.Account.Detail.Response
            ) {
                self.token = token
                self.user = user
            }
        }
    }
}
