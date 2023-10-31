import Common
import Entities
import Vapor

protocol DataController {
    func fetchResults<T: Codable>(
        at endpoint: EndpointProtocol,
        for req: Request,
        decodeResult: (ContentContainer) throws -> T
    ) async throws -> T
}

extension DataController {
    func fetchResults<T: Codable>(
        at endpoint: EndpointProtocol,
        for req: Request,
        decodeResult: (ContentContainer) throws -> T
    ) async throws -> T {
        guard let url = endpoint.url else { throw .urlNotFound(endpoint.path) }
    
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
            throw .decodingError(String(describing: T.self), nil)
        }
    }
}
