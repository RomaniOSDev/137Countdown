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
    var countMode: EventCountMode
    var emotion: EventMood
    var goal: String?
    var stories: [EventStoryEntry]
    var customMilestoneDays: [Int]

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
        milestoneCheckpointsEnabled: Bool = true,
        countMode: EventCountMode = .countdown,
        emotion: EventMood = .neutral,
        goal: String? = nil,
        stories: [EventStoryEntry] = [],
        customMilestoneDays: [Int] = []
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
        self.countMode = countMode
        self.emotion = emotion
        self.goal = goal
        self.stories = stories
        self.customMilestoneDays = customMilestoneDays
    }

    /// Next occurrence used for countdown, list dates, and notifications.
    var displayDate: Date {
        EventOccurrence.nextOccurrence(anchor: date, rule: recurrenceRule, notBefore: Date())
    }

    private var signedDaysToTarget: Int {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let startOfTarget = calendar.startOfDay(for: displayDate)
        let components = calendar.dateComponents([.day], from: startOfToday, to: startOfTarget)
        return components.day ?? 0
    }

    var daysLeft: Int {
        switch countMode {
        case .countdown:
            return signedDaysToTarget
        case .countUp:
            return signedDaysToTarget < 0 ? abs(signedDaysToTarget) : signedDaysToTarget
        }
    }

    var isPast: Bool {
        signedDaysToTarget < 0
    }

    var isToday: Bool {
        signedDaysToTarget == 0
    }

    var milestoneDays: [Int] {
        var values = customMilestoneDays.filter { $0 > 0 }
        if milestoneCheckpointsEnabled {
            values.append(contentsOf: [30, 7, 1])
        }
        return Array(Set(values)).sorted(by: >)
    }

    var statusText: String {
        switch countMode {
        case .countdown:
            if isPast {
                let absDays = abs(signedDaysToTarget)
                if absDays == 1 { return "1 day ago" }
                return "\(absDays) days ago"
            } else if isToday {
                return "Today!"
            } else {
                if signedDaysToTarget == 1 { return "1 day left" }
                return "\(signedDaysToTarget) days left"
            }
        case .countUp:
            if isPast {
                let value = abs(signedDaysToTarget)
                if value == 1 { return "1 day since" }
                return "\(value) days since"
            } else if isToday {
                return "Starts today"
            } else {
                if signedDaysToTarget == 1 { return "Starts in 1 day" }
                return "Starts in \(signedDaysToTarget) days"
            }
        }
    }

    var formattedDate: String {
        DateFormatting.mediumDate.string(from: displayDate)
    }

    var formattedDateTime: String {
        DateFormatting.mediumDateTime.string(from: displayDate)
    }

    var daysUnitDetail: String {
        switch countMode {
        case .countdown:
            if isPast { return "" }
            if signedDaysToTarget == 1 { return "day" }
            return "days"
        case .countUp:
            if isPast {
                return abs(signedDaysToTarget) == 1 ? "day since" : "days since"
            }
            return signedDaysToTarget == 1 ? "day" : "days"
        }
    }
}

extension Event: Codable {
    private enum CodingKeys: String, CodingKey {
        case id, title, date, category, notes, location, reminder, customReminderDays, imageName, isFavorite, createdAt
        case colorTag, recurrenceRule
        case isSpotlight, tags, milestoneCheckpointsEnabled
        case countMode, emotion, goal, stories, customMilestoneDays
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
        countMode = try container.decodeIfPresent(EventCountMode.self, forKey: .countMode) ?? .countdown
        emotion = try container.decodeIfPresent(EventMood.self, forKey: .emotion) ?? .neutral
        goal = try container.decodeIfPresent(String.self, forKey: .goal)
        stories = try container.decodeIfPresent([EventStoryEntry].self, forKey: .stories) ?? []
        customMilestoneDays = try container.decodeIfPresent([Int].self, forKey: .customMilestoneDays) ?? []
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
        try container.encode(countMode, forKey: .countMode)
        try container.encode(emotion, forKey: .emotion)
        try container.encodeIfPresent(goal, forKey: .goal)
        try container.encode(stories, forKey: .stories)
        try container.encode(customMilestoneDays, forKey: .customMilestoneDays)
    }
}
