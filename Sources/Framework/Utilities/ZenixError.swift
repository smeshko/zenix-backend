import Foundation
import Vapor

public enum ZenixErrorType {
    case urlNotFound(String)
    case decodingError(String, String?)
    case internalError(String)
    case creatorCannotLeaveContest
    case userAlreadyParticipantInContest
    case userNotInContest
    
}

public protocol ZenixErrorProtocol: Error, AbortError {
    var type: ZenixErrorType { get }
    var statusCode: Int { get }
    var additionalInformation: String { get }
}

public struct ZenixError: ZenixErrorProtocol {
    public init(type: ZenixErrorType) {
        self.type = type
    }
    
    public let type: ZenixErrorType
    public var reason: String { additionalInformation }
    public var status: HTTPStatus { HTTPStatus(statusCode: statusCode) }

    public var statusCode: Int {
        switch type {
        case .creatorCannotLeaveContest, .userNotInContest, .userAlreadyParticipantInContest:
            return 400
        case .urlNotFound:
            return 404
        case .decodingError, .internalError:
            return 500
        }
    }
    
    public var additionalInformation: String {
        switch type {
        case .creatorCannotLeaveContest:
            return "Contest creator cannot leave a contest. Try deleting it instead"
        case .userNotInContest:
            return "User is not participating in the given contest"
        case .userAlreadyParticipantInContest:
            return "User is already a prticipant in the given contest"
        case .urlNotFound(let url):
            return "URL \(url) not found"
        case let .decodingError(type, path):
            return "There was an issue decoding object of type \"\(type)\", missing value for key \"\(path ?? "no_key_found")\""
        case let .internalError(additionalInfo):
            return "An unexpected error occurred: \(additionalInfo)"
        }
    }
}
