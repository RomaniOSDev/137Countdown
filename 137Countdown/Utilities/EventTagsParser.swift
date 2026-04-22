//
//  EventTagsParser.swift
//  137Countdown
//

import Foundation

enum EventTagsParser {
    static func parse(_ raw: String) -> [String] {
        raw
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { !$0.isEmpty }
    }

    static func displayString(from tags: [String]) -> String {
        tags.joined(separator: ", ")
    }
}
