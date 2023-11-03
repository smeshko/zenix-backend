import Vapor

struct RootController {
    func routes(_ req: Request) async throws -> [String] {
        req.application.routes.all.map(\.pretty)
    }
}

extension Route {
    var pretty: String {
        "\(method.rawValue) \(path.map(\.description).joined(separator: "/"))"
    }
}
