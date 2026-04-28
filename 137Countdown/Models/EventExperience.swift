//
//  EventExperience.swift
//  137Countdown
//

import Foundation

enum EventCountMode: String, CaseIterable, Codable, Identifiable {
    case countdown = "Countdown"
    case countUp = "Count-up"

    var id: String { rawValue }
}

enum EventMood: String, CaseIterable, Codable, Identifiable {
    case neutral = "Calm"
    case excited = "Excited"
    case focused = "Focused"
    case grateful = "Grateful"
    case ambitious = "Ambitious"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .neutral: return "leaf.fill"
        case .excited: return "sparkles"
        case .focused: return "target"
        case .grateful: return "hands.clap.fill"
        case .ambitious: return "flame.fill"
        }
    }
}

struct EventStoryEntry: Identifiable, Hashable, Codable {
    let id: UUID
    var date: Date
    var note: String
    /// Optional local image path or short marker.
    var imageReference: String?

    init(id: UUID = UUID(), date: Date = Date(), note: String, imageReference: String? = nil) {
        self.id = id
        self.date = date
        self.note = note
        self.imageReference = imageReference
    }
}
