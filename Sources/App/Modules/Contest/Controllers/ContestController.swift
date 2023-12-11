import Vapor
import Fluent
import Entities

private let maximumSimultaneousContests = 3
private let maximumSimultaneousParticipations = 5

struct ContestController {
    func create(_ req: Request) async throws -> Contest.Create.Response {
        let user = try req.auth.require(UserAccountModel.self)
        let contestRequest = try req.content.decode(Contest.Create.Request.self)
        let contest = try ContestModel(from: contestRequest, creatorID: user.requireID())
        
        guard let account = try await req.tradingAccounts.find(id: contestRequest.tradingAccountId) else {
            throw ContestError.tradingAccountDoesntExist
        }
        
        guard try account.user.requireID() == user.requireID() else {
            throw ContestError.tradingAccountIncorrect
        }
        
        try await account.canParticipate(in: contest, for: req)
        try await req.contests.create(contest)

        try await req.contestParticipants.attach(user, to: contest) { pivot in
            pivot.role = .creator
            pivot.$tradingAccount.id = try account.requireID()
        }
        
        return try .init(
            from: contest,
            creator: .init(from: user)
        )
    }
    
    func publish(_ req: Request) async throws -> Contest.Details.Response {
        let contestID = try req.parameters.require("contestID", as: UUID.self)
        
        guard let contest = try await req.contests.find(id: contestID) else {
            throw ContestError.contestNotFound
        }
        
        contest.status = .ready
        try await req.contests.update(contest)
        
        let creator = try User.Account.List.Response(from: contest.creator)
        let contestParticipants = try contest.participants
            .map(User.Account.List.Response.init(from:))
                
        return try .init(
            from: contest,
            creator: creator,
            participants: contestParticipants
        )
    }

    func delete(_ req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(UserAccountModel.self)
        let contestID = try req.parameters.require("contestID", as: UUID.self)

        guard let contest = try await req.contests.find(id: contestID) else {
            throw ContestError.contestNotFound
        }
        
        guard contest.creator.id == user.id else {
            throw AuthenticationError.userNotAuthorized
        }

        try await req.contests.delete(id: contest.requireID())
        
        return .ok
    }

    func join(_ req: Request) async throws -> Contest.Join.Response {
        let user = try req.auth.require(UserAccountModel.self)
        let joinRequest = try req.content.decode(Contest.Join.Request.self)
        let contestID = try req.parameters.require("contestID", as: UUID.self)
        
        guard let account = try await req.tradingAccounts.find(id: joinRequest.tradingAccountId) else {
            throw ContestError.tradingAccountDoesntExist
        }

        guard let contest = try await req.contests.find(id: contestID) else {
            throw ContestError.contestNotFound
        }
        
        guard contest.status == .ready else {
            throw ContestError.enrollmentExpired
        }
        
        guard !req.application.calendar.isDateInToday(contest.startDate) else {
            throw ContestError.enrollmentExpired
        }
        
        let status = try await req.clients.market.marketStatus()
        if req.application.calendar.isDateInTomorrow(contest.startDate),
           status == .closedForTheDay {
            throw ContestError.enrollmentExpired
        }
        
        try await account.canParticipate(in: contest, for: req)

        guard !contest.participants.contains(where: { $0.id == user.id }),
              try contest.creator.requireID() != user.requireID() else {
            throw ContestError.userAlreadyParticipantInContest
        }
        
        try await req.contestParticipants.attach(user, to: contest) { pivot in
            pivot.role = .participant
        }
        
        let creator = try User.Account.List.Response(from: contest.creator)
        let contestParticipants = try contest.participants
            .map(User.Account.List.Response.init(from:))
                
        return try .init(
            from: contest,
            creator: creator,
            participants: contestParticipants
        )
    }
    
    func list(_ req: Request) async throws -> [Contest.List.Response] {
        try await req.contests.all().map {
            try Contest.List.Response(
                from: $0,
                participants: $0.participants.count
            )
        }
    }

    func leave(_ req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(UserAccountModel.self)
        let contestID = try req.parameters.require("contestID", as: UUID.self)

        guard let contest = try await req.contests.find(id: contestID) else {
            throw ContestError.contestNotFound
        }
        
        guard contest.creator.id != user.id else {
            throw ContestError.creatorCannotLeaveContest
        }

        guard contest.participants.contains(where: { $0.id == user.id }) else {
            throw ContestError.userNotInContest
        }
        
        try await req.contestParticipants.detach(user, from: contest)
        
        return .ok
    }
}

private extension TradingAccountModel {
    @discardableResult
    func canParticipate(in contest: ContestModel, for req: Request) async throws -> Bool {
        let user = try req.auth.require(UserAccountModel.self)
        let accountContests = try await req.contestParticipants.contests(for: user)
            .filter { ![ContestModel.Status.archived, .draft].contains($0.contest.status) }
            .filter { $0.tradingAccount?.id == id }
        
        let ownContests = accountContests.filter { $0.role == .creator }
        
        guard ownContests.count < maximumSimultaneousContests,
              accountContests.count < maximumSimultaneousParticipations else {
            throw ContestError.maxNumberOfContestsExceeded
        }
        
        for account in accountContests {
            if contest.startDate.isBetween(account.contest.startDate, and: account.contest.endDate) ||
                contest.endDate.isBetween(account.contest.startDate, and: account.contest.endDate) {
                throw ContestError.schedulingConflict
            }
        }

        return true
    }
}
