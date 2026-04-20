//
//  HomeView.swift
//  137Countdown
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: CountdownViewModel
    @Binding var selectedTab: Int

    @State private var path: [Event] = []
    @State private var showAddEvent = false

    private static let headerDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMMM d"
        f.locale = Locale(identifier: "en_US")
        return f
    }()

    private var greeting: String {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
        case 5 ..< 12: return "Good morning"
        case 12 ..< 17: return "Good afternoon"
        case 17 ..< 22: return "Good evening"
        default: return "Good night"
        }
    }

    private var spotlightEvent: Event? {
        viewModel.events
            .filter { !$0.isPast }
            .sorted { $0.displayDate < $1.displayDate }
            .first
    }

    private var weekInterval: DateInterval? {
        Calendar.current.dateInterval(of: .weekOfYear, for: Date())
    }

    private var eventsThisWeekCount: Int {
        guard let w = weekInterval else { return 0 }
        return viewModel.events.filter { e in
            !e.isPast && e.displayDate >= w.start && e.displayDate < w.end
        }.count
    }

    private var upcomingQueue: [Event] {
        let sorted = viewModel.events.filter { !$0.isPast }.sorted { $0.displayDate < $1.displayDate }
        guard let first = sorted.first else { return [] }
        return Array(sorted.dropFirst().prefix(5))
    }

    private var favoriteUpcoming: [Event] {
        viewModel.events
            .filter { $0.isFavorite && !$0.isPast }
            .sorted { $0.displayDate < $1.displayDate }
            .prefix(4)
            .map { $0 }
    }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    headerBlock

                    if let event = spotlightEvent {
                        spotlightWidget(event)
                    } else {
                        emptySpotlightWidget
                    }

                    statsRow

                    if !upcomingQueue.isEmpty {
                        upcomingWidget
                    }

                    if !favoriteUpcoming.isEmpty {
                        favoritesWidget
                    }

                    quoteWidget

                    quickNavGrid
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
            }
            .background(Color.clear)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.regularMaterial, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Home")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(
                            LinearGradient(colors: [.countdownAccent, Color(red: 1, green: 0.32, blue: 0.05)], startPoint: .leading, endPoint: .trailing)
                        )
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddEvent = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, Color.countdownAccent)
                            .font(.title2)
                    }
                    .accessibilityLabel("Add event")
                }
            }
            .navigationDestination(for: Event.self) { event in
                EventDetailView(viewModel: viewModel, event: event)
            }
            .sheet(isPresented: $showAddEvent) {
                AddEventView(viewModel: viewModel)
            }
        }
    }

    private var headerBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(greeting)
                .font(.title2.weight(.bold))
                .foregroundColor(.black)
            Text(Self.headerDateFormatter.string(from: Date()))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 8)
    }

    private func spotlightWidget(_ event: Event) -> some View {
        NavigationLink(value: event) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.countdownAccent.opacity(0.12),
                                Color.white
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(Color.countdownAccent.opacity(0.22), lineWidth: 1)

                HStack(alignment: .top, spacing: 0) {
                    Capsule()
                        .fill(event.colorTag == .none ? Color.countdownAccent : event.colorTag.stripeColor)
                        .frame(width: 5)
                        .padding(.vertical, 20)
                        .padding(.leading, 4)

                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Label("Next up", systemImage: "sparkles")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.countdownAccent)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.secondary)
                        }

                        HStack(alignment: .center, spacing: 20) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(event.title)
                                    .font(.title3.weight(.bold))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2)

                                HStack(spacing: 8) {
                                    Image(systemName: event.category.icon)
                                        .foregroundColor(event.colorTag == .none ? .countdownAccent : event.colorTag.stripeColor)
                                    Text(event.formattedDateTime)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    if event.recurrenceRule != .none {
                                        Image(systemName: "repeat")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }

                            Spacer(minLength: 8)

                            if event.isToday {
                                VStack(spacing: 2) {
                                    Text("TODAY")
                                        .font(.caption.weight(.heavy))
                                        .foregroundColor(.countdownAccent)
                                    Text("!")
                                        .font(.title2.weight(.bold))
                                        .foregroundColor(.countdownAccent)
                                }
                                .frame(minWidth: 72)
                            } else {
                                VStack(spacing: 0) {
                                    Text("\(event.daysLeft)")
                                        .font(.system(size: 44, weight: .bold, design: .rounded))
                                        .foregroundColor(.countdownAccent)
                                    Text(event.daysLeft == 1 ? "day left" : "days left")
                                        .font(.caption2.weight(.medium))
                                        .foregroundColor(.secondary)
                                }
                                .frame(minWidth: 72)
                            }
                        }
                    }
                    .padding(.vertical, 20)
                    .padding(.trailing, 18)
                    .padding(.leading, 8)
                }
            }
            .shadow(color: Color.black.opacity(0.12), radius: 28, x: 0, y: 16)
            .shadow(color: Color.countdownAccent.opacity(0.1), radius: 20, x: 0, y: 10)
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }

    private var emptySpotlightWidget: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .font(.title2)
                    .foregroundColor(.countdownAccent)
                Text("No upcoming events")
                    .font(.headline)
                    .foregroundColor(.black)
            }
            Text("Add something you are looking forward to — we will count the days for you.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                showAddEvent = true
            } label: {
                Text("Create event")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(CountdownVisual.primaryButton)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(CountdownVisual.primaryButtonStroke, lineWidth: 1)
                    )
                    .shadow(color: Color.countdownAccent.opacity(0.38), radius: 14, x: 0, y: 6)
            }
            .padding(.top, 4)
        }
        .padding(22)
        .countdownRaisedCard(cornerRadius: 24, panel: false)
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            HomeStatPill(
                title: "Today",
                value: "\(viewModel.todayEventsCount)",
                icon: "sun.max.fill",
                tint: .countdownAccent
            )
            HomeStatPill(
                title: "This week",
                value: "\(eventsThisWeekCount)",
                icon: "calendar.badge.clock",
                tint: .countdownAccent
            )
            HomeStatPill(
                title: "Active",
                value: "\(viewModel.activeEventsCount)",
                icon: "bolt.fill",
                tint: .countdownAccent
            )
        }
    }

    private var upcomingWidget: some View {
        VStack(alignment: .leading, spacing: 12) {
            widgetHeader(title: "Coming up", icon: "list.bullet.rectangle", actionTab: 1)

            VStack(spacing: 0) {
                ForEach(Array(upcomingQueue.enumerated()), id: \.element.id) { index, event in
                    NavigationLink(value: event) {
                        HomeEventRow(event: event)
                    }
                    .buttonStyle(.plain)
                    if index < upcomingQueue.count - 1 {
                        Divider().padding(.leading, 52)
                    }
                }
            }
            .padding(.vertical, 4)
            .countdownRaisedCard(cornerRadius: 20, panel: false)
        }
    }

    private var favoritesWidget: some View {
        VStack(alignment: .leading, spacing: 12) {
            widgetHeader(title: "Favorite picks", icon: "star.fill", actionTab: 1)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(favoriteUpcoming) { event in
                        NavigationLink(value: event) {
                            HomeFavoriteChip(event: event)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private var quoteWidget: some View {
        VStack(alignment: .leading, spacing: 12) {
            widgetHeader(title: "Daily quote", icon: "quote.opening", actionTab: 3)

            let q = viewModel.quoteOfTheDay
            VStack(alignment: .leading, spacing: 10) {
                Text(q.text)
                    .font(.subheadline)
                    .italic()
                    .foregroundColor(.black)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                Text("— \(q.author)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .countdownRaisedCard(cornerRadius: 20, panel: true)
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color.countdownAccent.opacity(0.35), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
        }
    }

    private var quickNavGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Shortcuts")
                .font(.headline)
                .foregroundColor(.black)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                HomeShortcutTile(title: "Events", icon: "calendar", tabIndex: 1, selectedTab: $selectedTab)
                HomeShortcutTile(title: "Calendar", icon: "calendar.day.timeline.left", tabIndex: 2, selectedTab: $selectedTab)
                HomeShortcutTile(title: "Inspiration", icon: "quote.opening", tabIndex: 3, selectedTab: $selectedTab)
                HomeShortcutTile(title: "Archive", icon: "archivebox.fill", tabIndex: 4, selectedTab: $selectedTab)
            }
        }
        .padding(.top, 4)
    }

    private func widgetHeader(title: String, icon: String, actionTab: Int) -> some View {
        HStack {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundColor(.black)
            Spacer()
            Button {
                selectedTab = actionTab
            } label: {
                Text("Open")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.countdownAccent)
            }
        }
    }
}

// MARK: - Subviews

private struct HomeStatPill: View {
    let title: String
    let value: String
    let icon: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(tint)
            Text(title)
                .font(.caption2.weight(.medium))
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundColor(.black)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .countdownRaisedCard(cornerRadius: 16, panel: false)
    }
}

private struct HomeEventRow: View {
    let event: Event

    private var accent: Color {
        event.colorTag == .none ? Color.countdownAccent : event.colorTag.stripeColor
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(accent.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: event.category.icon)
                    .font(.body.weight(.semibold))
                    .foregroundColor(accent)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.black)
                    .lineLimit(1)
                Text(event.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer(minLength: 8)

            if event.isToday {
                Text("Today")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.countdownAccent)
            } else {
                VStack(alignment: .trailing, spacing: 0) {
                    Text("\(event.daysLeft)")
                        .font(.headline.weight(.bold))
                        .foregroundColor(event.daysLeft <= 7 ? Color.countdownAccent : .black)
                    Text("days")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundColor(.secondary.opacity(0.7))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
}

private struct HomeFavoriteChip: View {
    let event: Event

    private var accent: Color {
        event.colorTag == .none ? Color.countdownAccent : event.colorTag.stripeColor
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundColor(.countdownAccent)
                Spacer()
                Text(event.isToday ? "Today" : "\(event.daysLeft)d")
                    .font(.caption2.weight(.bold))
                    .foregroundColor(accent)
            }
            Text(event.title)
                .font(.caption.weight(.semibold))
                .foregroundColor(.black)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(width: 132, alignment: .leading)
        }
        .padding(12)
        .frame(width: 156, alignment: .leading)
        .countdownRaisedCard(cornerRadius: 16, panel: false)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [accent.opacity(0.45), accent.opacity(0.12)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

private struct HomeShortcutTile: View {
    let title: String
    let icon: String
    let tabIndex: Int
    @Binding var selectedTab: Int

    var body: some View {
        Button {
            selectedTab = tabIndex
        } label: {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.countdownAccent)
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .countdownRaisedCard(cornerRadius: 16, panel: false)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView(viewModel: CountdownViewModel(), selectedTab: .constant(0))
}
