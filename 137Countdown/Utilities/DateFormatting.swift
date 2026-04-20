//
//  DateFormatting.swift
//  137Countdown
//

import Foundation

enum DateFormatting {
    private static let english = Locale(identifier: "en_US_POSIX")

    static let mediumDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        formatter.locale = english
        return formatter
    }()

    static let mediumDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy, HH:mm"
        formatter.locale = english
        return formatter
    }()

    static let shortNumeric: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        formatter.locale = english
        return formatter
    }()
}

func formattedDate(_ date: Date) -> String {
    DateFormatting.mediumDate.string(from: date)
}

func formattedShortDate(_ date: Date) -> String {
    DateFormatting.shortNumeric.string(from: date)
}
