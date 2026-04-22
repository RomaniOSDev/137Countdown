//
//  EventsTimelineView.swift
//  137Countdown
//

import SwiftUI

private enum TimelineRow: Identifiable {
    case upcoming(Event)
    case completed(CompletedEvent)

    var id: String {
        switch self {
        case .upcoming(let e): return "u-\(e.id.uuidString)"
        case .completed(let c): return "c-\(c.id.uuidString)"
        }
    }
}

struct EventsTimelineView: View {
    @ObservedObject var viewModel: CountdownViewModel

    @State private var categoryFilter: EventCategory?
    @State private var searchText = ""

    private var rows: [TimelineRow] {
        let cal = Calendar.current
        let now = Date()
        let recentCutoff = cal.date(byAdding: .day, value: -14, to: now) ?? now

        let upcoming = viewModel.events
            .filter { e in
                guard categoryFilter == nil || e.category == categoryFilter else { return false }
                return matchesSearch(e)
            }
            .sorted { $0.displayDate < $1.displayDate }
            .map { TimelineRow.upcoming($0) }

        let recentDone = viewModel.completedEvents
            .filter { c in
                guard c.completedDate >= recentCutoff else { return false }
                if let categoryFilter, c.category != categoryFilter { return false }
                return matchesCompletedSearch(c)
            }
            .sorted { $0.completedDate > $1.completedDate }
            .map { TimelineRow.completed($0) }

        return upcoming + recentDone
    }

    private func matchesSearch(_ event: Event) -> Bool {
        viewModel.matchesTimelineSearch(event: event, text: searchText)
    }

    private func matchesCompletedSearch(_ c: CompletedEvent) -> Bool {
        let t = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return true }
        return c.title.localizedCaseInsensitiveContains(t)
            || (c.notes ?? "").localizedCaseInsensitiveContains(t)
    }

    var body: some View {
        List {
            Section {
                Picker("Category", selection: $categoryFilter) {
                    Text("All").tag(Optional<EventCategory>.none)
                    ForEach(EventCategory.allCases, id: \.self) { cat in
                        Text(cat.rawValue).tag(Optional(cat))
                    }
                }
                .pickerStyle(.menu)
            }

            if rows.isEmpty {
                Text("Nothing on the timeline yet. Add an event or complete one to see it here.")
                    .foregroundColor(.secondary)
                    .listRowBackground(Color.clear)
            } else {
                ForEach(rows) { row in
                    switch row {
                    case .upcoming(let event):
                        NavigationLink(value: event) {
                            TimelineUpcomingRow(event: event)
                        }
                        .listRowBackground(Color.clear)
                    case .completed(let done):
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.secondary)
                                Text(done.title)
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(done.completedDate, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Text("Completed · was \(DateFormatting.mediumDate.string(from: done.date))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(Color.clear)
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .searchable(text: $searchText, prompt: "Search title, notes, tags")
    }
}

private struct TimelineUpcomingRow: View {
    let event: Event

    private var accent: Color {
        event.colorTag == .none ? Color.countdownAccent : event.colorTag.stripeColor
    }

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(accent.opacity(0.2))
                .frame(width: 10, height: 10)
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(event.title)
                        .font(.headline)
                        .foregroundColor(.black)
                    if event.isSpotlight {
                        Image(systemName: "pin.fill")
                            .font(.caption2)
                            .foregroundColor(.countdownAccent)
                    }
                }
                Text(event.formattedDateTime)
                    .font(.caption)
                    .foregroundColor(.secondary)
                if !event.tags.isEmpty {
                    Text(event.tags.map { "#\($0)" }.joined(separator: " "))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            if event.isToday {
                Text("Today")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.countdownAccent)
            } else if event.isPast {
                Text("Past")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                VStack(alignment: .trailing, spacing: 0) {
                    Text("\(event.daysLeft)")
                        .font(.title3.weight(.bold))
                        .foregroundColor(accent)
                    Text("days")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
