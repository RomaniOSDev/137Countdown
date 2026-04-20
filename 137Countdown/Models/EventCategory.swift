//
//  EventCategory.swift
//  137Countdown
//

import Foundation

enum EventCategory: String, CaseIterable, Codable {
    case birthday = "Birthday"
    case holiday = "Holiday"
    case vacation = "Vacation"
    case wedding = "Wedding"
    case exam = "Exam"
    case deadline = "Deadline"
    case meeting = "Meeting"
    case travel = "Travel"
    case concert = "Concert"
    case other = "Other"

    var icon: String {
        switch self {
        case .birthday: return "gift.fill"
        case .holiday: return "star.fill"
        case .vacation: return "beach.umbrella.fill"
        case .wedding: return "heart.fill"
        case .exam: return "book.fill"
        case .deadline: return "clock.fill"
        case .meeting: return "person.2.fill"
        case .travel: return "airplane"
        case .concert: return "music.note"
        case .other: return "calendar"
        }
    }
}
