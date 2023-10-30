import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
}

public protocol EndpointProtocol {
    var path: String { get }
    var url: URL? { get }
    var method: HTTPMethod { get }
    var host: String { get }
    var body: Data? { get }
    var headers: [String: String] { get }
    var postfix: String? { get }
    var queryParameters: [String: String]? { get }
    
    var cacheKey: String { get }
    var cacheTTL: TimeInterval { get }
}
