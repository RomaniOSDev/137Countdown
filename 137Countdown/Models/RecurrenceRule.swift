//
//  RecurrenceRule.swift
//  137Countdown
//

import Foundation

enum RecurrenceRule: String, CaseIterable, Codable {
    case none
    case daily
    case weekly
    case monthly
    case yearly

    var displayName: String {
        switch self {
        case .none: return "Does not repeat"
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        }
    }
}
