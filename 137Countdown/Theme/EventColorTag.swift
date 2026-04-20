//
//  EventColorTag.swift
//  137Countdown
//

import SwiftUI

enum EventColorTag: String, CaseIterable, Codable {
    case none
    case coral
    case sky
    case mint
    case lavender
    case lemon
    case slate

    var displayName: String {
        switch self {
        case .none: return "Default"
        case .coral: return "Coral"
        case .sky: return "Sky"
        case .mint: return "Mint"
        case .lavender: return "Lavender"
        case .lemon: return "Lemon"
        case .slate: return "Slate"
        }
    }

    /// Accent stripe / icon tint (default uses app accent in views).
    var stripeColor: Color {
        switch self {
        case .none: return .countdownAccent
        case .coral: return Color(red: 1.0, green: 0.35, blue: 0.25)
        case .sky: return Color(red: 0.2, green: 0.55, blue: 0.95)
        case .mint: return Color(red: 0.1, green: 0.72, blue: 0.55)
        case .lavender: return Color(red: 0.55, green: 0.45, blue: 0.95)
        case .lemon: return Color(red: 0.95, green: 0.78, blue: 0.2)
        case .slate: return Color(red: 0.35, green: 0.4, blue: 0.48)
        }
    }
}
