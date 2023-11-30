import Vapor
import JWT
import Entities

struct UserPayloadAuthenticator: AsyncJWTAuthenticator {
    typealias Payload = Entities.Payload
    
    func authenticate(jwt: Payload, for request: Request) async throws {
        request.auth.login(jwt)
    }
}
