import Entities
import Vapor

extension ContestError: AppError {}

extension ContestError: AbortError {
    public var status: HTTPResponseStatus {
        switch self {
        case .contestNotFound: .notFound
        case .userAlreadyParticipantInContest: .badRequest
        case .userNotInContest: .badRequest
        case .creatorCannotLeaveContest: .badRequest
        case .enrollmentExpired: .badRequest
        case .maxNumberOfContestsExceeded: .badRequest
        case .schedulingConflict: .badRequest
        case .tradingAccountDoesntExist: .badRequest
        case .tradingAccountIncorrect: .badRequest
        }
    }
}
