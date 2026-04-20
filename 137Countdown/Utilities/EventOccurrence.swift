//
//  EventOccurrence.swift
//  137Countdown
//

import Foundation

enum EventOccurrence {
    /// Next occurrence instant on or after `notBefore` (uses `Calendar.current` and anchor time-of-day).
    static func nextOccurrence(anchor: Date, rule: RecurrenceRule, notBefore: Date) -> Date {
        switch rule {
        case .none:
            return anchor
        case .daily:
            return nextDaily(anchor: anchor, notBefore: max(notBefore, anchor))
        case .weekly:
            return nextWeekly(anchor: anchor, notBefore: max(notBefore, anchor))
        case .monthly:
            return nextMonthly(anchor: anchor, notBefore: max(notBefore, anchor))
        case .yearly:
            return nextYearly(anchor: anchor, notBefore: max(notBefore, anchor))
        }
    }

    /// Whether the event has any occurrence on the given calendar day (start-of-day semantics).
    static func occursOnCalendarDay(anchor: Date, rule: RecurrenceRule, day: Date) -> Bool {
        let cal = Calendar.current
        let start = cal.startOfDay(for: day)
        guard let end = cal.date(byAdding: .day, value: 1, to: start) else { return false }
        let next = nextOccurrence(anchor: anchor, rule: rule, notBefore: start)
        return next >= start && next < end
    }

    private static func nextDaily(anchor: Date, notBefore: Date) -> Date {
        let cal = Calendar.current
        let h = cal.component(.hour, from: anchor)
        let m = cal.component(.minute, from: anchor)
        let s = cal.component(.second, from: anchor)
        var day = cal.startOfDay(for: notBefore)
        for _ in 0 ..< 800 {
            if let dt = cal.date(bySettingHour: h, minute: m, second: s, of: day), dt >= notBefore {
                return dt
            }
            guard let nextDay = cal.date(byAdding: .day, value: 1, to: day) else { break }
            day = nextDay
        }
        return anchor
    }

    private static func nextWeekly(anchor: Date, notBefore: Date) -> Date {
        let cal = Calendar.current
        let targetWeekday = cal.component(.weekday, from: anchor)
        let h = cal.component(.hour, from: anchor)
        let mi = cal.component(.minute, from: anchor)
        let s = cal.component(.second, from: anchor)
        var day = cal.startOfDay(for: notBefore)
        for _ in 0 ..< 800 {
            if cal.component(.weekday, from: day) == targetWeekday {
                if let dt = cal.date(bySettingHour: h, minute: mi, second: s, of: day), dt >= notBefore {
                    return dt
                }
            }
            guard let nextDay = cal.date(byAdding: .day, value: 1, to: day) else { break }
            day = nextDay
        }
        return anchor
    }

    private static func nextMonthly(anchor: Date, notBefore: Date) -> Date {
        let cal = Calendar.current
        let dom = cal.component(.day, from: anchor)
        let h = cal.component(.hour, from: anchor)
        let mi = cal.component(.minute, from: anchor)
        let s = cal.component(.second, from: anchor)
        guard var monthDate = cal.date(from: cal.dateComponents([.year, .month], from: notBefore)) else {
            return anchor
        }
        for _ in 0 ..< 1_200 {
            guard let dayRange = cal.range(of: .day, in: .month, for: monthDate) else { break }
            let maxDay = dayRange.upperBound - 1
            let day = min(dom, maxDay)
            let y = cal.component(.year, from: monthDate)
            let mo = cal.component(.month, from: monthDate)
            if let d0 = cal.date(from: DateComponents(year: y, month: mo, day: day)),
               let dt = cal.date(bySettingHour: h, minute: mi, second: s, of: d0),
               dt >= notBefore {
                return dt
            }
            guard let nextMonth = cal.date(byAdding: .month, value: 1, to: monthDate) else { break }
            monthDate = nextMonth
        }
        return anchor
    }

    private static func nextYearly(anchor: Date, notBefore: Date) -> Date {
        let cal = Calendar.current
        let month = cal.component(.month, from: anchor)
        let dom = cal.component(.day, from: anchor)
        let h = cal.component(.hour, from: anchor)
        let mi = cal.component(.minute, from: anchor)
        let s = cal.component(.second, from: anchor)
        var year = cal.component(.year, from: notBefore)
        for _ in 0 ..< 50 {
            let day = clampDayOfMonth(year: year, month: month, desiredDay: dom, calendar: cal)
            if let d0 = cal.date(from: DateComponents(year: year, month: month, day: day)),
               let dt = cal.date(bySettingHour: h, minute: mi, second: s, of: d0),
               dt >= notBefore {
                return dt
            }
            year += 1
        }
        return anchor
    }

    private static func clampDayOfMonth(year: Int, month: Int, desiredDay: Int, calendar cal: Calendar) -> Int {
        guard let d1 = cal.date(from: DateComponents(year: year, month: month, day: 1)),
              let range = cal.range(of: .day, in: .month, for: d1) else {
            return desiredDay
        }
        let maxDay = range.upperBound - 1
        return min(desiredDay, maxDay)
    }
}
