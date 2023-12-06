import Vapor

extension Application {
    var calendar: Calendar {
        .init(identifier: .gregorian)
    }
}
