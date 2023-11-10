import Vapor

struct ContestRouter: RouteCollection {
    
    let controller = ContestController()
    
    func boot(routes: RoutesBuilder) throws {
        let contestApi = routes
            .grouped("api")
            .grouped("contest")
            .grouped(UserTokenAuthenticator())

        contestApi.post("create", use: controller.create)
        contestApi.get("list", use: controller.list)
        
        let contestIdApi = contestApi
            .grouped(":contestID")

        contestIdApi.post("join", use: controller.join)
        contestIdApi.post("leave", use: controller.leave)
        contestIdApi.delete("delete", use: controller.delete)
    }
}
