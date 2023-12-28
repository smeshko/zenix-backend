import Vapor

struct RootController {
    func routes(_ req: Request) async throws -> [String] {
        let json = try await req.client.get(URI(string: "https://shark-app-l7ciw.ondigitalocean.app/.well-known/apple-app-site-association"))

        return req.application.routes.all.map(\.pretty)
    }
}

extension Route {
    var pretty: String {
        "\(method.rawValue) \(path.map(\.description).joined(separator: "/"))"
    }
}
