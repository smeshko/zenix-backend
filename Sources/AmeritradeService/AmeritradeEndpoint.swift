import Foundation
import Entities

/// An enum used to route the different types of requests.
public enum AmeritradeEndpoint: EndpointProtocol {
    // auth
    case refresh(_ refreshToken: String, _ clientId: String)
        
    public var path: String {
        switch self {
        case .refresh: return "/v1/oauth2/token"
        }
    }

    public var url: URL? {
        UrlBuilder(endpoint: self)
            .components()
            .queryItems()
            .build()
    }

    public var queryParameters: [String: String]? {
        return nil
    }

    public var host: String {
        return "api.tdameritrade.com"
    }

    public var method: HTTPMethod {
        switch self {
        case .refresh: return .post
        }
    }

    public var body: Data? {
        switch self {
        case let .refresh(refreshToken, clientId):
            return "grant_type=refresh_token&client_id=\(clientId)&&refresh_token=\(refreshToken.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!)".data(using: .utf8)
        }
    }

    public var headers: [String: String] {
        ["Content-Type" : "application/x-www-form-urlencoded"]
    }
}
