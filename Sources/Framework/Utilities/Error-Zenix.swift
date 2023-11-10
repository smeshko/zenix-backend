import Vapor

public extension Error where Self == ZenixError {
    static func decodingError(_ decodedType: String, _ missingKey: String?) -> ZenixError {
        ZenixError(type: .decodingError(decodedType, missingKey))
    }
    
    static func urlNotFound(_ url: String) -> ZenixError {
        ZenixError(type: .urlNotFound(url))
    }
    
    static func internalError(_ info: String?) -> ZenixError {
        ZenixError(type: .internalError(info ?? ""))
    }
    
    static func creatorCannotLeaveContest() -> ZenixError {
        .init(type: .creatorCannotLeaveContest)
    }
    
    static func userAlreadyParticipantInContest() -> ZenixError {
        .init(type: .userAlreadyParticipantInContest)
    }
    
    static func userNotInContest() -> ZenixError {
        .init(type: .userNotInContest)
    }
}
