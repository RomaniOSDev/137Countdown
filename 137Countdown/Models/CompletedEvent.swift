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
}
