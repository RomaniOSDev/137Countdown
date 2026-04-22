//
//  Event.swift
//  137Countdown
//

import Foundation

struct Event: Identifiable, Hashable {
    let id: UUID
    var title: String
    var date: Date
    var category: EventCategory
    var notes: String?
    var location: String?
    var reminder: ReminderType
    var customReminderDays: Int?
    var imageName: String?
    var isFavorite: Bool
    let createdAt: Date
    var colorTag: EventColorTag
    var recurrenceRule: RecurrenceRule
    /// Pinned “main” event for Home and sharing.
    var isSpotlight: Bool
    /// User-defined text tags (lowercased for search).
    var tags: [String]
    /// Schedule milestone notifications at 30, 7, and 1 day before the event (start of target day).
    var milestoneCheckpointsEnabled: Bool

    init(
        id: UUID,
        title: String,
        date: Date,
        category: EventCategory,
        notes: String?,
        location: String?,
        reminder: ReminderType,
        customReminderDays: Int?,
        imageName: String?,
        isFavorite: Bool,
        createdAt: Date,
        colorTag: EventColorTag = .none,
        recurrenceRule: RecurrenceRule = .none,
        isSpotlight: Bool = false,
        tags: [String] = [],
        milestoneCheckpointsEnabled: Bool = true
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.category = category
        self.notes = notes
        self.location = location
        self.reminder = reminder
        self.customReminderDays = customReminderDays
        self.imageName = imageName
        self.isFavorite = isFavorite
        self.createdAt = createdAt
        self.colorTag = colorTag
        self.recurrenceRule = recurrenceRule
        self.isSpotlight = isSpotlight
        self.tags = tags
        self.milestoneCheckpointsEnabled = milestoneCheckpointsEnabled
    }

    /// Next occurrence used for countdown, list dates, and notifications.
    var displayDate: Date {
        EventOccurrence.nextOccurrence(anchor: date, rule: recurrenceRule, notBefore: Date())
    }

    var daysLeft: Int {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let startOfTarget = calendar.startOfDay(for: displayDate)
        let components = calendar.dateComponents([.day], from: startOfToday, to: startOfTarget)
        return components.day ?? 0
    }

    var isPast: Bool {
        daysLeft < 0
    }

    var isToday: Bool {
        daysLeft == 0
    }

    var statusText: String {
        if isPast {
            let absDays = abs(daysLeft)
            if absDays == 1 { return "1 day ago" }
            return "\(absDays) days ago"
        } else if isToday {
            return "Today!"
        } else {
            if daysLeft == 1 { return "1 day left" }
            return "\(daysLeft) days left"
        }
    }

    var formattedDate: String {
        DateFormatting.mediumDate.string(from: displayDate)
    }

    var formattedDateTime: String {
        DateFormatting.mediumDateTime.string(from: displayDate)
    }

    var daysUnitDetail: String {
        if isPast { return "" }
        if daysLeft == 1 { return "day" }
        return "days"
    }
}

extension Event: Codable {
    private enum CodingKeys: String, CodingKey {
        case id, title, date, category, notes, location, reminder, customReminderDays, imageName, isFavorite, createdAt
        case colorTag, recurrenceRule
        case isSpotlight, tags, milestoneCheckpointsEnabled
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        date = try container.decode(Date.self, forKey: .date)
        category = try container.decode(EventCategory.self, forKey: .category)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        location = try container.decodeIfPresent(String.self, forKey: .location)
        reminder = try container.decode(ReminderType.self, forKey: .reminder)
        customReminderDays = try container.decodeIfPresent(Int.self, forKey: .customReminderDays)
        imageName = try container.decodeIfPresent(String.self, forKey: .imageName)
        isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        colorTag = try container.decodeIfPresent(EventColorTag.self, forKey: .colorTag) ?? .none
        recurrenceRule = try container.decodeIfPresent(RecurrenceRule.self, forKey: .recurrenceRule) ?? .none
        isSpotlight = try container.decodeIfPresent(Bool.self, forKey: .isSpotlight) ?? false
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        milestoneCheckpointsEnabled = try container.decodeIfPresent(Bool.self, forKey: .milestoneCheckpointsEnabled) ?? true
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(date, forKey: .date)
        try container.encode(category, forKey: .category)
        try container.encodeIfPresent(notes, forKey: .notes)
        try container.encodeIfPresent(location, forKey: .location)
        try container.encode(reminder, forKey: .reminder)
        try container.encodeIfPresent(customReminderDays, forKey: .customReminderDays)
        try container.encodeIfPresent(imageName, forKey: .imageName)
        try container.encode(isFavorite, forKey: .isFavorite)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(colorTag, forKey: .colorTag)
        try container.encode(recurrenceRule, forKey: .recurrenceRule)
        try container.encode(isSpotlight, forKey: .isSpotlight)
        try container.encode(tags, forKey: .tags)
        try container.encode(milestoneCheckpointsEnabled, forKey: .milestoneCheckpointsEnabled)
    }
}
