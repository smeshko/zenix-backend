import Foundation

extension Date {
    var noon: Date {
        let existing = Calendar.current.dateComponents([.year, .month, .day], from: self)
        var new = DateComponents()
        new.year = existing.year
        new.month = existing.month
        new.day = existing.day
        new.hour = 12
        return Calendar.current.date(from: new) ?? .now
    }

    func isBetween(_ startDate: Date, and endDate: Date) -> Bool {
        startDate <= self && self < endDate
    }

}
