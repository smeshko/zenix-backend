public protocol InvestmentServiceController {
    func refreshToken(_ token: String, clientId: String) async throws
}
