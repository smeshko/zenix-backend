import Entities
import Common
import Vapor

/// Provides functionality for fetching data at a specific endpoint.
///
/// See `EndpointProtocol`
public protocol DataController {
    /// Asynchronously fetches data at the provided endpoint.
    /// - Parameters:
    ///   - endpoint: the endpoint which to call. The protocol encapsulates all the properties needed to build a request
    ///   - req: a Vapor object representing a request
    ///   - decodeResult: this callback provides the response's content and allows any additional manipulations to be done before returning the result
    /// - Returns: the object that was decoded in `decodeResult`
    func fetchResults<T: Codable>(
        at endpoint: Endpoint,
        for req: Request,
        decodeResult: (ContentContainer) throws -> T
    ) async throws -> T
    
    /// Asynchronously fetches data at the provided endpoint.
    /// - Parameters:
    ///   - endpoint: the endpoint which to call. The protocol encapsulates all the properties needed to build a request
    ///   - req: a Vapor object representing a request
    /// - Returns: the object that was decoded from the API response
    func fetchResults<T: Codable>(
        at endpoint: Endpoint,
        for req: Request
    ) async throws -> T
    
    /// Asynchronously fetches data at the provided endpoint.
    /// - Parameters:
    ///   - endpoint: the endpoint which to call. The protocol encapsulates all the properties needed to build a request
    ///   - req: a Vapor object representing a request
    ///   - decoder: a content decoder to use to decode the response. Check `func fetchResults<T: Codable>(at endpoint: EndpointProtocol, for req: Request)` if you want to use the default `JSONDecoder`.
    /// - Returns: the object that was decoded from the API response
    func fetchResults<T: Codable>(
        at endpoint: Endpoint,
        for req: Request,
        decoder: ContentDecoder
    ) async throws -> T
}

public extension DataController {
    
    func fetchResults<T: Codable>(
        at endpoint: Endpoint,
        for req: Request
    ) async throws -> T {
        try await fetchResults(at: endpoint, for: req) { content in
            try content.decode(T.self, using: JSONDecoder())
        }
    }
    
    func fetchResults<T: Codable>(
        at endpoint: Endpoint,
        for req: Request,
        decoder: ContentDecoder
    ) async throws -> T {
        try await fetchResults(at: endpoint, for: req) { content in
            try content.decode(T.self, using: decoder)
        }
    }
    
    func fetchResults<T: Codable>(
        at endpoint: Endpoint,
        for req: Request,
        decodeResult: (ContentContainer) throws -> T
    ) async throws -> T {
        guard let url = endpoint.url else { throw Abort(.notFound) }
    
        let response = try await req.client.get(
            URI(url: url),
            headers: HTTPHeaders(endpoint.headers.map { ($0.key, $0.value) })
        ) { request in
            try request.query.encode(endpoint.queryParameters ?? [:])
            req.logger.info("Starting request: \(request)")
        }
        
        req.logger.info("Received response: \(response)")
        
        do {
            return try decodeResult(response.content)
        } catch _ as DecodingError {
            throw Abort(.badRequest)
        }
    }
}
