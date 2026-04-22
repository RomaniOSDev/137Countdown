//
//  EventCalendarExport.swift
//  137Countdown
//

import Foundation

enum EventCalendarExport {
    /// RFC 5545 single-event calendar for sharing as `.ics`.
    static func icsDocument(for event: Event) -> String {
        let cal = Calendar.current
        let uid = "\(event.id.uuidString)@137countdown"
        let stamp = icsDate(Date(), calendar: cal)
        let start = icsDate(event.displayDate, calendar: cal)
        let end = icsDate(cal.date(byAdding: .hour, value: 1, to: event.displayDate) ?? event.displayDate, calendar: cal)

        let summary = escapeText(event.title)
        let loc = event.location.map { escapeText($0) } ?? ""
        let descParts = [event.notes, event.tags.isEmpty ? nil : "Tags: \(event.tags.joined(separator: ", "))"].compactMap { $0 }.joined(separator: "\\n")
        let desc = escapeText(descParts)

        return """
        BEGIN:VCALENDAR
        VERSION:2.0
        PRODID:-//137Countdown//EN
        CALSCALE:GREGORIAN
        BEGIN:VEVENT
        UID:\(uid)
        DTSTAMP:\(stamp)
        DTSTART:\(start)
        DTEND:\(end)
        SUMMARY:\(summary)
        LOCATION:\(loc)
        DESCRIPTION:\(desc)
        END:VEVENT
        END:VCALENDAR
        """
    }

    private static func icsDate(_ date: Date, calendar: Calendar) -> String {
        let c = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let y = c.year ?? 0
        let m = c.month ?? 0
        let d = c.day ?? 0
        let h = c.hour ?? 0
        let min = c.minute ?? 0
        let s = c.second ?? 0
        return String(format: "%04d%02d%02dT%02d%02d%02d", y, m, d, h, min, s)
    }

    private static func escapeText(_ s: String) -> String {
        s
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: ";", with: "\\;")
            .replacingOccurrences(of: ",", with: "\\,")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "")
    }
}
