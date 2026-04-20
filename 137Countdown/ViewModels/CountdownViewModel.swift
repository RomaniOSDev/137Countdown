//
//  CountdownViewModel.swift
//  137Countdown
//

import Combine
import Foundation
import SwiftUI
import UserNotifications

@MainActor
final class CountdownViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var quotes: [Quote] = []
    @Published var completedEvents: [CompletedEvent] = []

    var totalEvents: Int { events.count }

    var activeEventsCount: Int {
        events.filter { !$0.isPast }.count
    }

    var todayEventsCount: Int {
        events.filter { $0.isToday }.count
    }

    /// Nearest upcoming event (ignores list filters).
    var nearestEventTitle: String {
        events
            .filter { !$0.isPast && !$0.isToday }
            .sorted { $0.displayDate < $1.displayDate }
            .first?
            .title ?? "—"
    }

    var favoriteQuotes: [Quote] {
        quotes.filter { $0.isFavorite }
    }

    var quoteOfTheDay: Quote {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        guard !quotes.isEmpty else {
            return Quote(
                id: UUID(),
                text: "Live every day as if it were a celebration.",
                author: "Unknown",
                isFavorite: false
            )
        }
        return quotes[dayOfYear % quotes.count]
    }

    func upcomingEvents(search: String, scope: EventFilterScope, category: EventCategory?) -> [Event] {
        listEvents(search: search, scope: scope, category: category, sort: .dateAscending)
            .filter { !$0.isPast && !$0.isToday }
            .sorted { $0.displayDate < $1.displayDate }
            .prefix(5)
            .map { $0 }
    }

    func listEvents(search: String, scope: EventFilterScope, category: EventCategory?, sort: EventSortOption) -> [Event] {
        let filtered = events.filter { event in
            matchesSearch(event, text: search) && matchesFilter(event, scope: scope, category: category)
        }
        return sortEvents(filtered, by: sort)
    }

    func quotesMatching(search: String) -> [Quote] {
        let q = search.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return quotes }
        return quotes.filter {
            $0.text.localizedCaseInsensitiveContains(q) || $0.author.localizedCaseInsensitiveContains(q)
        }
    }

    func hasEvent(on date: Date) -> Bool {
        events.contains { EventOccurrence.occursOnCalendarDay(anchor: $0.date, rule: $0.recurrenceRule, day: date) }
    }

    func eventCount(on date: Date) -> Int {
        events.filter { EventOccurrence.occursOnCalendarDay(anchor: $0.date, rule: $0.recurrenceRule, day: date) }.count
    }

    func eventsOnDate(_ date: Date) -> [Event] {
        events
            .filter { EventOccurrence.occursOnCalendarDay(anchor: $0.date, rule: $0.recurrenceRule, day: date) }
            .sorted { $0.displayDate < $1.displayDate }
    }

    func addEvent(_ event: Event) {
        events.append(event)
        scheduleNotification(for: event)
        saveToUserDefaults()
    }

    func updateEvent(_ event: Event) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            cancelNotification(for: events[index])
            events[index] = event
            scheduleNotification(for: event)
            saveToUserDefaults()
        }
    }

    func deleteEvent(_ event: Event) {
        events.removeAll { $0.id == event.id }
        cancelNotification(for: event)

        let completed = CompletedEvent(
            id: UUID(),
            eventId: event.id,
            title: event.title,
            date: event.displayDate,
            completedDate: Date(),
            notes: event.notes
        )
        completedEvents.append(completed)

        saveToUserDefaults()
    }

    func restoreEvent(_ completed: CompletedEvent) {
        let restoredEvent = Event(
            id: completed.eventId,
            title: completed.title,
            date: completed.date,
            category: .other,
            notes: completed.notes,
            location: nil,
            reminder: .none,
            customReminderDays: nil,
            imageName: nil,
            isFavorite: false,
            createdAt: Date(),
            colorTag: .none,
            recurrenceRule: .none
        )
        events.append(restoredEvent)
        completedEvents.removeAll { $0.id == completed.id }
        saveToUserDefaults()
    }

    func deleteCompletedEvent(_ completed: CompletedEvent) {
        completedEvents.removeAll { $0.id == completed.id }
        saveToUserDefaults()
    }

    func toggleFavorite(_ event: Event) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index].isFavorite.toggle()
            saveToUserDefaults()
        }
    }

    func duplicateEvent(_ event: Event) {
        let newEvent = Event(
            id: UUID(),
            title: "\(event.title) (copy)",
            date: event.date,
            category: event.category,
            notes: event.notes,
            location: event.location,
            reminder: event.reminder,
            customReminderDays: event.customReminderDays,
            imageName: nil,
            isFavorite: false,
            createdAt: Date(),
            colorTag: event.colorTag,
            recurrenceRule: event.recurrenceRule
        )
        events.append(newEvent)
        scheduleNotification(for: newEvent)
        saveToUserDefaults()
    }

    func addQuote(_ quote: Quote) {
        quotes.append(quote)
        saveToUserDefaults()
    }

    func updateQuote(_ quote: Quote) {
        if let index = quotes.firstIndex(where: { $0.id == quote.id }) {
            quotes[index] = quote
            saveToUserDefaults()
        }
    }

    func deleteQuote(_ quote: Quote) {
        quotes.removeAll { $0.id == quote.id }
        saveToUserDefaults()
    }

    func toggleQuoteFavorite(_ quote: Quote) {
        if let index = quotes.firstIndex(where: { $0.id == quote.id }) {
            quotes[index].isFavorite.toggle()
            saveToUserDefaults()
        }
    }

    func moveQuotes(from source: IndexSet, to destination: Int) {
        quotes.move(fromOffsets: source, toOffset: destination)
        saveToUserDefaults()
    }

    private func matchesSearch(_ event: Event, text: String) -> Bool {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return true }
        return event.title.localizedCaseInsensitiveContains(t)
            || (event.location ?? "").localizedCaseInsensitiveContains(t)
            || (event.notes ?? "").localizedCaseInsensitiveContains(t)
    }

    private func matchesFilter(_ event: Event, scope: EventFilterScope, category: EventCategory?) -> Bool {
        if let category, event.category != category { return false }
        switch scope {
        case .all:
            return true
        case .favorites:
            return event.isFavorite
        case .today:
            return event.isToday
        case .thisWeek:
            guard let interval = Calendar.current.dateInterval(of: .weekOfYear, for: Date()) else { return false }
            let d = event.displayDate
            return d >= interval.start && d < interval.end
        }
    }

    private func sortEvents(_ events: [Event], by sort: EventSortOption) -> [Event] {
        switch sort {
        case .dateAscending:
            return events.sorted { $0.displayDate < $1.displayDate }
        case .dateDescending:
            return events.sorted { $0.displayDate > $1.displayDate }
        case .titleAZ:
            return events.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .titleZA:
            return events.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedDescending }
        case .daysRemainingAsc:
            return events.sorted { $0.daysLeft < $1.daysLeft }
        case .daysRemainingDesc:
            return events.sorted { $0.daysLeft > $1.daysLeft }
        }
    }

    private func scheduleNotification(for event: Event) {
        let target = event.displayDate
        guard target > Date() else { return }

        var reminderDays = 0
        switch event.reminder {
        case .onDay:
            reminderDays = 0
        case .dayBefore:
            reminderDays = 1
        case .weekBefore:
            reminderDays = 7
        case .monthBefore:
            reminderDays = 30
        case .custom:
            reminderDays = event.customReminderDays ?? 0
        case .none:
            return
        }

        guard let notificationDate = Calendar.current.date(byAdding: .day, value: -reminderDays, to: target),
              notificationDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        if reminderDays == 0 {
            content.body = "“\(event.title)” is today."
        } else if reminderDays == 1 {
            content.body = "“\(event.title)” is in 1 day."
        } else {
            content.body = "“\(event.title)” is in \(reminderDays) days."
        }
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: event.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func cancelNotification(for event: Event) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [event.id.uuidString])
    }

    private func rescheduleAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        for event in events where event.displayDate > Date() && event.reminder != .none {
            scheduleNotification(for: event)
        }
    }

    private let eventsKey = "countdown_events"
    private let quotesKey = "countdown_quotes"
    private let completedKey = "countdown_completed"

    func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(events) {
            UserDefaults.standard.set(encoded, forKey: eventsKey)
        }
        if let encoded = try? JSONEncoder().encode(quotes) {
            UserDefaults.standard.set(encoded, forKey: quotesKey)
        }
        if let encoded = try? JSONEncoder().encode(completedEvents) {
            UserDefaults.standard.set(encoded, forKey: completedKey)
        }
    }

    func loadFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: eventsKey),
           let decoded = try? JSONDecoder().decode([Event].self, from: data) {
            events = decoded
        }

        if let data = UserDefaults.standard.data(forKey: quotesKey),
           let decoded = try? JSONDecoder().decode([Quote].self, from: data) {
            quotes = decoded
        }

        if let data = UserDefaults.standard.data(forKey: completedKey),
           let decoded = try? JSONDecoder().decode([CompletedEvent].self, from: data) {
            completedEvents = decoded
        }

        if events.isEmpty {
            loadDemoData()
        }

        rescheduleAllNotifications()
    }

    private func loadDemoData() {
        let nextYear = Calendar.current.component(.year, from: Date()) + 1
        let event1 = Event(
            id: UUID(),
            title: "New Year",
            date: Calendar.current.date(from: DateComponents(year: nextYear, month: 1, day: 1)) ?? Date(),
            category: .holiday,
            notes: "Family gathering",
            location: "Home",
            reminder: .weekBefore,
            customReminderDays: nil,
            imageName: nil,
            isFavorite: true,
            createdAt: Date(),
            colorTag: .coral,
            recurrenceRule: .yearly
        )

        let event2 = Event(
            id: UUID(),
            title: "Birthday",
            date: Calendar.current.date(byAdding: .day, value: 25, to: Date()) ?? Date(),
            category: .birthday,
            notes: "Gift is ready",
            location: "Restaurant",
            reminder: .dayBefore,
            customReminderDays: nil,
            imageName: nil,
            isFavorite: false,
            createdAt: Date(),
            colorTag: .lavender,
            recurrenceRule: .yearly
        )

        let event3 = Event(
            id: UUID(),
            title: "Vacation",
            date: Calendar.current.date(byAdding: .day, value: 45, to: Date()) ?? Date(),
            category: .vacation,
            notes: "Tickets booked",
            location: "Sea",
            reminder: .monthBefore,
            customReminderDays: nil,
            imageName: nil,
            isFavorite: true,
            createdAt: Date(),
            colorTag: .sky,
            recurrenceRule: .none
        )

        events = [event1, event2, event3]

        let quote1 = Quote(id: UUID(), text: "Every day is a new opportunity.", author: "Unknown", isFavorite: true)
        let quote2 = Quote(id: UUID(), text: "Happiness is a way of life, not a destination.", author: "Unknown", isFavorite: false)

        quotes = [quote1, quote2]
        saveToUserDefaults()
    }
}
