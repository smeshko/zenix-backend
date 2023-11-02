import Foundation

public enum ZenixErrorType {
    case urlNotFound(String)
    case decodingError(String, String?)
    case internalError(String)
}

public protocol ZenixErrorProtocol: Error {
    var type: ZenixErrorType { get }
    var statusCode: Int { get }
    var additionalInformation: String { get }
}

public struct ZenixError: ZenixErrorProtocol {
    public init(type: ZenixErrorType) {
        self.type = type
    }
    
    public let type: ZenixErrorType

    public var statusCode: Int {
        switch type {
        case .urlNotFound:
            return 404
        case .decodingError, .internalError:
            return 500
        }
    }
    
    public var additionalInformation: String {
        switch type {
        case .urlNotFound(let url):
            return "URL \(url) not found"
        case let .decodingError(type, path):
            return "There was an issue decoding object of type \"\(type)\", missing value for key \"\(path ?? "no_key_found")\""
        case let .internalError(additionalInfo):
            return "An unexpected error occurred: \(additionalInfo)"
        }
    }
}
