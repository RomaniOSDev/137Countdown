//
//  EventTemplate.swift
//  137Countdown
//

import Foundation

enum EventTemplatePack: String, CaseIterable, Identifiable {
    case life = "Life moments"
    case growth = "Growth goals"
    case travel = "Travel plans"

    var id: String { rawValue }
}

struct EventTemplate: Identifiable, Hashable {
    let id: String
    let pack: EventTemplatePack
    let title: String
    let category: EventCategory
    let daysFromNow: Int
    let reminder: ReminderType
    let customReminderDays: Int?
    let notes: String?
    let colorTag: EventColorTag
    let recurrenceRule: RecurrenceRule
    let defaultTags: [String]
    let symbolName: String
    let defaultMood: EventMood
    let defaultGoal: String?
    let defaultMilestones: [Int]
    let countMode: EventCountMode

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
        EventTemplate(id: "birthday", pack: .life, title: "Birthday", category: .birthday, daysFromNow: 30, reminder: .weekBefore, customReminderDays: nil, notes: "Plan gift and dinner.", colorTag: .lavender, recurrenceRule: .yearly, defaultTags: ["family", "celebration"], symbolName: "gift.fill", defaultMood: .grateful, defaultGoal: "Make this day special.", defaultMilestones: [14, 3], countMode: .countdown),
        EventTemplate(id: "anniversary", pack: .life, title: "Anniversary", category: .holiday, daysFromNow: 60, reminder: .monthBefore, customReminderDays: nil, notes: "Book a place and prepare surprise.", colorTag: .coral, recurrenceRule: .yearly, defaultTags: ["love", "life"], symbolName: "heart.fill", defaultMood: .grateful, defaultGoal: "Create a meaningful memory.", defaultMilestones: [30, 10], countMode: .countdown),
        EventTemplate(id: "exam", pack: .growth, title: "Exam day", category: .exam, daysFromNow: 21, reminder: .custom, customReminderDays: 7, notes: "Review chapters and solve past papers.", colorTag: .sky, recurrenceRule: .none, defaultTags: ["study"], symbolName: "book.fill", defaultMood: .focused, defaultGoal: "Pass with confidence.", defaultMilestones: [14, 5, 2], countMode: .countdown),
        EventTemplate(id: "habit", pack: .growth, title: "Habit streak start", category: .other, daysFromNow: 0, reminder: .onDay, customReminderDays: nil, notes: "Track consistency daily.", colorTag: .mint, recurrenceRule: .none, defaultTags: ["habit", "self-growth"], symbolName: "flame.fill", defaultMood: .ambitious, defaultGoal: "Build a 100-day streak.", defaultMilestones: [7, 30, 100], countMode: .countUp),
        EventTemplate(id: "trip", pack: .travel, title: "Trip", category: .travel, daysFromNow: 14, reminder: .weekBefore, customReminderDays: nil, notes: "Check passport, tickets, and packing list.", colorTag: .sky, recurrenceRule: .none, defaultTags: ["travel"], symbolName: "airplane.departure", defaultMood: .excited, defaultGoal: "Travel stress-free.", defaultMilestones: [10, 3], countMode: .countdown),
        EventTemplate(id: "vacation", pack: .travel, title: "Vacation starts", category: .vacation, daysFromNow: 45, reminder: .monthBefore, customReminderDays: nil, notes: "Confirm hotel and transport.", colorTag: .lemon, recurrenceRule: .none, defaultTags: ["rest", "summer"], symbolName: "beach.umbrella.fill", defaultMood: .excited, defaultGoal: "Finish prep early.", defaultMilestones: [21, 7], countMode: .countdown)
    ]
}
