//
//  CompletedEvent.swift
//  137Countdown
//

import Foundation

struct CompletedEvent: Identifiable, Codable, Hashable {
    let id: UUID
    let eventId: UUID
    var title: String
    var date: Date
    var completedDate: Date
    var notes: String?
    var category: EventCategory?

    init(
        id: UUID,
        eventId: UUID,
        title: String,
        date: Date,
        completedDate: Date,
        notes: String?,
        category: EventCategory? = nil
    ) {
        self.id = id
        self.eventId = eventId
        self.title = title
        self.date = date
        self.completedDate = completedDate
        self.notes = notes
        self.category = category
    }
}
