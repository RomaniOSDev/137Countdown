//
//  CalendarView.swift
//  137Countdown
//

import SwiftUI

struct CalendarView: View {
    @ObservedObject var viewModel: CountdownViewModel

    @State private var path: [Event] = []
    @State private var displayedMonth = Date()
    @State private var selectedDate: Date?

    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 2
        return cal
    }

    private static let monthYearFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "LLLL yyyy"
        f.locale = Locale(identifier: "en_US")
        return f
    }()

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Calendar")
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(
                            LinearGradient(colors: [.countdownAccent, Color(red: 1, green: 0.32, blue: 0.05)], startPoint: .leading, endPoint: .trailing)
                        )
                        .shadow(color: Color.countdownAccent.opacity(0.2), radius: 6, y: 2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                    monthGrid

                    if let selectedDate {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(formattedDate(selectedDate))
                                .font(.headline)
                                .foregroundColor(.black)
                                .padding(.horizontal)

                            ForEach(viewModel.eventsOnDate(selectedDate)) { event in
                                NavigationLink(value: event) {
                                    MiniEventCard(event: event)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(.vertical)
            }
            .background(Color.clear)
            .navigationDestination(for: Event.self) { event in
                EventDetailView(viewModel: viewModel, event: event)
            }
            .toolbarBackground(.regularMaterial, for: .navigationBar)
        }
    }

    private var monthGrid: some View {
        VStack(spacing: 14) {
            HStack {
                monthNavButton(systemName: "chevron.left", action: previousMonth)

                Spacer()

                Text(Self.monthYearFormatter.string(from: displayedMonth))
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.black)

                Spacer()

                monthNavButton(systemName: "chevron.right", action: nextMonth)
            }
            .padding(.horizontal, 4)

            HStack {
                ForEach(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"], id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.secondary)
                        .font(.caption.weight(.medium))
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, date in
                    if let date {
                        CalendarDayCell(
                            calendar: calendar,
                            date: date,
                            hasEvent: viewModel.hasEvent(on: date),
                            eventCount: viewModel.eventCount(on: date)
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedDate = date
                        }
                    } else {
                        Color.clear
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
        }
        .padding(18)
        .countdownRaisedCard(cornerRadius: 22, panel: false)
        .padding(.horizontal)
    }

    private func monthNavButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.body.weight(.semibold))
                .foregroundStyle(
                    LinearGradient(colors: [.countdownAccent, Color(red: 1, green: 0.32, blue: 0.05)], startPoint: .top, endPoint: .bottom)
                )
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Circle()
                                .strokeBorder(CountdownVisual.cardStroke, lineWidth: 0.5)
                        )
                )
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
                .shadow(color: Color.white.opacity(0.7), radius: 1, x: 0, y: -1)
        }
        .buttonStyle(.plain)
    }

    private var daysInMonth: [Date?] {
        let cal = calendar
        guard let monthStart = cal.date(from: cal.dateComponents([.year, .month], from: displayedMonth)) else {
            return []
        }

        let weekday = cal.component(.weekday, from: monthStart)
        let leading = (weekday - cal.firstWeekday + 7) % 7
        guard let range = cal.range(of: .day, in: .month, for: monthStart) else {
            return []
        }

        var cells: [Date?] = Array(repeating: nil, count: leading)
        for day in range {
            if let date = cal.date(byAdding: .day, value: day - 1, to: monthStart) {
                cells.append(date)
            }
        }

        while cells.count % 7 != 0 {
            cells.append(nil)
        }
        return cells
    }

    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: displayedMonth) {
            displayedMonth = newDate
        }
    }

    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: displayedMonth) {
            displayedMonth = newDate
        }
    }
}
