import Vapor
import Fluent
import Entities

struct ContestController {
    func create(_ req: Request) async throws -> Contest.Create.Response {
        let user = try req.auth.require(UserAccountModel.self)
        let contestRequest = try req.content.decode(Contest.Create.Request.self)
        let contest = try ContestModel(from: contestRequest, creatorID: user.requireID())
        
        try await req.contests.create(contest)
        try await req.contests.attach(user, to: contest) { pivot in
            pivot.role = .creator
        }
        
        return try .init(
            from: contest,
            creator: .init(from: user)
        )
    }
    
    func publish(_ req: Request) async throws -> Contest.Details.Response {
        let user = try req.auth.require(UserAccountModel.self)
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
        let contestID = try req.parameters.require("contestID", as: UUID.self)

        guard let contest = try await req.contests.find(id: contestID) else {
            throw ContestError.contestNotFound
        }
        
        guard !contest.participants.contains(where: { $0.id == user.id }),
              try contest.creator.requireID() != user.requireID() else {
            throw ContestError.userAlreadyParticipantInContest
        }
        
        try await req.contests.attach(user, to: contest) { pivot in
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
        
        guard contest.participants.contains(where: { $0.id == user.id }) else {
            throw ContestError.userNotInContest
        }
        
        guard contest.creator.id != user.id else {
            throw ContestError.creatorCannotLeaveContest
        }
        
        try await req.contests.detach(user, from: contest)
        
        return .ok
    }
}
