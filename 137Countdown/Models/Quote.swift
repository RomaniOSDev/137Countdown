//
//  Quote.swift
//  137Countdown
//

import Foundation

struct Quote: Identifiable, Codable, Hashable {
    let id: UUID
    var text: String
    var author: String
    var isFavorite: Bool
}
