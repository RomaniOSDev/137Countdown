//
//  ReminderType.swift
//  137Countdown
//

import Foundation

enum ReminderType: String, CaseIterable, Codable {
    case none = "No reminder"
    case onDay = "On the event day"
    case dayBefore = "One day before"
    case weekBefore = "One week before"
    case monthBefore = "One month before"
    case custom = "Custom interval"

    var daysBefore: Int? {
        switch self {
        case .onDay: return 0
        case .dayBefore: return 1
        case .weekBefore: return 7
        case .monthBefore: return 30
        default: return nil
        }
    }
}
