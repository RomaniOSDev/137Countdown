//
//  AppExternalURL.swift
//  137Countdown
//

import Foundation

/// Central place for outbound links (privacy, terms, etc.). Replace hosts with your production URLs.
enum AppExternalURL: String, CaseIterable {
    case privacyPolicy
    case termsOfUse

    var url: URL? {
        switch self {
        case .privacyPolicy:
            return URL(string: "https://www.termsfeed.com/live/0d0d9f89-89fa-4ea3-86c5-cb87b3bf011f")
        case .termsOfUse:
            return URL(string: "https://www.termsfeed.com/live/7548aa56-29de-4d4e-88c9-fa7e8cc6063b")
        }
    }

    var menuTitle: String {
        switch self {
        case .privacyPolicy:
            return "Privacy Policy"
        case .termsOfUse:
            return "Terms of Use"
        }
    }
}
