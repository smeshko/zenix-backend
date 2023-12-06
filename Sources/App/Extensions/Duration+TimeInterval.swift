import Entities
import Foundation

extension Contest.Duration {
    var time: TimeInterval {
        switch self {
        case .day: 24.hours
        case .week: 7.days
        case .month: 30.days
        case .quarter: 90.days
        }
    }
}
