//
//  EventTemplate.swift
//  137Countdown
//

import Foundation

struct EventTemplate: Identifiable, Hashable {
    let id: String
    let title: String
    let category: EventCategory
    /// Days from today for the suggested target date.
    let daysFromNow: Int
    let reminder: ReminderType
    let customReminderDays: Int?
    let notes: String?
    let colorTag: EventColorTag
    let recurrenceRule: RecurrenceRule
    let defaultTags: [String]
    let symbolName: String

    var subtitle: String {
        switch daysFromNow {
        case 0: return "Today"
        case 1: return "Tomorrow"
        default: return "In \(daysFromNow) days"
        }
    }

    func suggestedDate(from now: Date = Date()) -> Date {
        Calendar.current.date(byAdding: .day, value: daysFromNow, to: now) ?? now
    }

    static let library: [EventTemplate] = [
        EventTemplate(
            id: "trip",
            title: "Trip",
            category: .travel,
            daysFromNow: 14,
            reminder: .weekBefore,
            customReminderDays: nil,
            notes: "Check passport and tickets.",
            colorTag: .sky,
            recurrenceRule: .none,
            defaultTags: ["travel", "plans"],
            symbolName: "airplane.departure"
        ),
        EventTemplate(
            id: "birthday",
            title: "Birthday",
            category: .birthday,
            daysFromNow: 30,
            reminder: .weekBefore,
            customReminderDays: nil,
            notes: "Gift ideas",
            colorTag: .lavender,
            recurrenceRule: .yearly,
            defaultTags: ["family", "celebration"],
            symbolName: "gift.fill"
        ),
        EventTemplate(
            id: "exam",
            title: "Exam day",
            category: .exam,
            daysFromNow: 21,
            reminder: .custom,
            customReminderDays: 7,
            notes: "Review chapters 1–5.",
            colorTag: .none,
            recurrenceRule: .none,
            defaultTags: ["study", "school"],
            symbolName: "book.fill"
        ),
        EventTemplate(
            id: "deadline",
            title: "Project deadline",
            category: .deadline,
            daysFromNow: 7,
            reminder: .dayBefore,
            customReminderDays: nil,
            notes: "Final polish and export.",
            colorTag: .coral,
            recurrenceRule: .none,
            defaultTags: ["work", "urgent"],
            symbolName: "flag.checkered"
        ),
        EventTemplate(
            id: "vacation",
            title: "Vacation starts",
            category: .vacation,
            daysFromNow: 60,
            reminder: .monthBefore,
            customReminderDays: nil,
            notes: "Pack and confirm hotel.",
            colorTag: .sky,
            recurrenceRule: .none,
            defaultTags: ["rest", "summer"],
            symbolName: "beach.umbrella.fill"
        ),
        EventTemplate(
            id: "concert",
            title: "Concert",
            category: .concert,
            daysFromNow: 10,
            reminder: .dayBefore,
            customReminderDays: nil,
            notes: "Doors time — arrive early.",
            colorTag: .lavender,
            recurrenceRule: .none,
            defaultTags: ["music", "friends"],
            symbolName: "music.note"
        )
    ]
}
