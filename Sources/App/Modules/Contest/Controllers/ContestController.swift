import Vapor
import Fluent
import Entities

struct ContestController {
    func create(_ req: Request) async throws -> Contest.Create.Response {
        let user = try req.auth.require(UserAccountModel.self)
        let contestRequest = try req.content.decode(Contest.Create.Request.self)
        let contest = try ContestModel(from: contestRequest, creatorID: user.requireID())
        
        try await req.contests.create(contest)
        
        try await contest.$participants.attach(user, on: req.db) { pivot in
            pivot.role = .creator
        }
        
        return try .init(
            from: contest,
            creator: .init(from: user)
        )
    }

    func delete(_ req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(UserAccountModel.self)
        let contestID = try req.parameters.require("contestID", as: UUID.self)

        guard let contest = try await req.contests.find(id: contestID) else {
            throw ContestError.contestNotFound
        }
        
        let creator = try await contest.$creator.get(on: req.db)
        guard creator.id == user.id else {
            throw AuthenticationError.userNotAuthorized
        }

        try await contest.delete(on: req.db)
        
        return .ok
    }

    func join(_ req: Request) async throws -> Contest.Join.Response {
        let user = try req.auth.require(UserAccountModel.self)
        let contestID = try req.parameters.require("contestID", as: UUID.self)

        guard let contest = try await req.contests.find(id: contestID) else {
            throw ContestError.contestNotFound
        }
        
        let participants = try await contest.$participants.get(on: req.db)
        
        guard !participants.contains(where: { $0.id == user.id }) else {
            throw ContestError.userAlreadyParticipantInContest
        }
        
        try await user.$contests.attach(contest, on: req.db) { pivot in
            pivot.role = .participant
        }
        
        let creator = try await User.Account.List.Response(from: contest.$creator.get(on: req.db))
        let contestParticipants = try participants
            .map(User.Account.List.Response.init(from:))
                
        return try .init(
            from: contest,
            creator: creator,
            participants: contestParticipants
        )
    }
    
    func list(_ req: Request) async throws -> [Contest.List.Response] {
        try await req.contests.all().asyncMap {
            try Contest.List.Response(
                from: $0,
                participants: try await $0.$participants.get(on: req.db).count
            )
        }
    }

    func leave(_ req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(UserAccountModel.self)
        let contestID = try req.parameters.require("contestID", as: UUID.self)

        guard let contest = try await req.contests.find(id: contestID) else {
            throw ContestError.contestNotFound
        }
        
        let participants = try await contest.$participants.get(on: req.db)
        let creator = try await contest.$creator.get(on: req.db)

        guard participants.contains(where: { $0.id == user.id }) else {
            throw ContestError.userNotInContest
        }
        guard creator.id != user.id else {
            throw ContestError.creatorCannotLeaveContest
        }
        
        try await contest.$participants.detach(user, on: req.db)
        
        return .ok
    }
}
