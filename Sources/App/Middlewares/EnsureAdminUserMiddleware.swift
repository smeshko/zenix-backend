import Vapor
import Entities

struct EnsureAdminUserMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        let payload = try request.auth.require(Payload.self)
        guard payload.isAdmin else {
            throw Abort(.unauthorized)
        }
        
        return try await next.respond(to: request)
    }
}
