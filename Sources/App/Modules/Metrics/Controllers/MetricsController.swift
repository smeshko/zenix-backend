import Vapor
import Metrics
import Prometheus

struct MetricsController {
    
    func getMetrics(_ req: Request) async throws -> String {
        try await MetricsSystem.prometheus().collect()
    }
}
