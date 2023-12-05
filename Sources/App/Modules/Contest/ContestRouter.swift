import Vapor

struct ContestRouter: RouteCollection {
    
    let controller = ContestController()
    
    func boot(routes: RoutesBuilder) throws {
        let contestAPI = routes
            .grouped("api")
            .grouped("contest")
        
        contestAPI.get("list", use: controller.list)

        let protectedContestAPI = contestAPI
            .grouped(UserPayloadAuthenticator())

        protectedContestAPI.post("create", use: controller.create)

        let contestIDAPI = protectedContestAPI
            .grouped(":contestID")

        contestIDAPI.post("join", use: controller.join)
        contestIDAPI.post("leave", use: controller.leave)
        contestIDAPI.delete("delete", use: controller.delete)
    }
}
