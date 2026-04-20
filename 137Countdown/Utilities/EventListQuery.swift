//
//  EventListQuery.swift
//  137Countdown
//

import Foundation

enum EventFilterScope: String, CaseIterable, Identifiable {
    case all
    case favorites
    case today
    case thisWeek

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "All"
        case .favorites: return "Favorites"
        case .today: return "Today"
        case .thisWeek: return "This week"
        }
    }
}

enum EventSortOption: String, CaseIterable, Identifiable {
    case dateAscending
    case dateDescending
    case titleAZ
    case titleZA
    case daysRemainingAsc
    case daysRemainingDesc

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dateAscending: return "Date (soonest first)"
        case .dateDescending: return "Date (latest first)"
        case .titleAZ: return "Title (A–Z)"
        case .titleZA: return "Title (Z–A)"
        case .daysRemainingAsc: return "Days left (ascending)"
        case .daysRemainingDesc: return "Days left (descending)"
        }
    }
}
