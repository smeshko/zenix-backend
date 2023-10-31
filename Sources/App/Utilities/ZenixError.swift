import Entities
import Vapor

extension Error where Self == ZenixError {
    static func decodingError(_ decodedType: String, _ missingKey: String?) -> ZenixError {
        ZenixError(type: .decodingError(decodedType, missingKey))
    }
    
    static func urlNotFound(_ url: String) -> ZenixError {
        ZenixError(type: .urlNotFound(url))
    }
    
    static func internalError(_ info: String?) -> ZenixError {
        ZenixError(type: .internalError(info ?? ""))
    }
}

extension ZenixError: AbortError {
    public var reason: String { additionalInformation }
    public var status: HTTPStatus { HTTPStatus(statusCode: statusCode) }
}
