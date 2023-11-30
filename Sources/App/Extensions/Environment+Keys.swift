import Vapor

extension Environment {
    static var brevoKey: String {
        Environment.get("BREVO_API_KEY") ?? ""
    }
    
    static var databaseURL: String {
        if let databaseURL = Environment.get("DATABASE_URL") {
            return databaseURL
        } else {
            fatalError("DATABASE_URL empty")
        }
    }
    
    static var baseURL: String {
        if let baseURL = Environment.get("BASE_URL") {
            return baseURL
        } else {
            fatalError("BASE_URL empty")
        }
    }
}
