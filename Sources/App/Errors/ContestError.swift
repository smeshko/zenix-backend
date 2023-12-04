import Vapor

enum ContestError: AppError {
    case contestNotFound
    case userAlreadyParticipantInContest
    case userNotInContest
    case creatorCannotLeaveContest
}

extension ContestError: AbortError {
    var status: HTTPResponseStatus {
        switch self {
        case .contestNotFound: .notFound
        case .userAlreadyParticipantInContest: .badRequest
        case .userNotInContest: .badRequest
        case .creatorCannotLeaveContest: .badRequest
        }
    }
    
    var reason: String {
        switch self {
        case .contestNotFound:
            "A contest with the given ID was not found."
        case .userAlreadyParticipantInContest:
            "User is already a prticipant in the given contest"
        case .userNotInContest:
            "User is not participating in the given contest"
        case .creatorCannotLeaveContest:
            "Contest creator cannot leave a contest. Try deleting it instead"
        }
    }
    
    var identifier: String {
        switch self {
        case .contestNotFound:
            "contest_not_found"
        case .userAlreadyParticipantInContest:
            "user_already_participant_in_contest"
        case .userNotInContest:
            "user_not_in_contest"
        case .creatorCannotLeaveContest:
            "creator_cannot_ceave_contest"
        }
    }
}
