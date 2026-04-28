//
//  EventsListView.swift
//  137Countdown
//

import SwiftUI
import UIKit

private enum EventsBrowserMode: String, CaseIterable {
    case list = "List"
    case timeline = "Timeline"
}

struct EventsListView: View {
    @ObservedObject var viewModel: CountdownViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @AppStorage("events_browser_mode") private var storedBrowserModeRaw = EventsBrowserMode.list.rawValue
    @AppStorage("events_selected_event_id") private var storedSelectedEventID = ""
    @AppStorage("events_search_text") private var storedSearchText = ""
    @AppStorage("events_filter_scope") private var storedFilterScopeRaw = EventFilterScope.all.rawValue
    @AppStorage("events_category_filter") private var storedCategoryFilterRaw = ""
    @AppStorage("events_sort_option") private var storedSortOptionRaw = EventSortOption.dateAscending.rawValue

    @State private var path: [Event] = []
    @State private var showAddEventSheet = false
    @State private var browserMode: EventsBrowserMode = .list
    @State private var templateForAdd: EventTemplate?
    @State private var showTemplateAdd = false
    @State private var selectedEventID: UUID?

    @State private var searchText = ""
    @State private var isSearchPresented = false
    @State private var filterScope: EventFilterScope = .all
    @State private var categoryFilter: EventCategory?
    @State private var sortOption: EventSortOption = .dateAscending

    private var isPadSplitLayout: Bool {
        horizontalSizeClass == .regular
    }

    private var selectedEvent: Event? {
        guard let selectedEventID else { return nil }
        return viewModel.events.first(where: { $0.id == selectedEventID })
    }

    private var displayedUpcoming: [Event] {
        viewModel.upcomingEvents(search: searchText, scope: filterScope, category: categoryFilter)
    }

    private var displayedList: [Event] {
        viewModel.listEvents(search: searchText, scope: filterScope, category: categoryFilter, sort: sortOption)
    }

    private static let subtitleFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMMM d"
        f.locale = Locale(identifier: "en_US")
        return f
    }()

    var body: some View {
        Group {
            if isPadSplitLayout {
                splitView
            } else {
                compactView
            }
        }
        .sheet(isPresented: $showAddEventSheet) {
            AddEventView(viewModel: viewModel)
        }
        .sheet(isPresented: $showTemplateAdd, onDismiss: { templateForAdd = nil }) {
            AddEventView(viewModel: viewModel, template: templateForAdd, onFinished: nil)
        }
        .onAppear {
            if let restoredMode = EventsBrowserMode(rawValue: storedBrowserModeRaw) {
                browserMode = restoredMode
            }
            if let restoredID = UUID(uuidString: storedSelectedEventID) {
                selectedEventID = restoredID
            }
            searchText = storedSearchText
            if let restoredScope = EventFilterScope(rawValue: storedFilterScopeRaw) {
                filterScope = restoredScope
            }
            categoryFilter = EventCategory(rawValue: storedCategoryFilterRaw)
            if let restoredSort = EventSortOption(rawValue: storedSortOptionRaw) {
                sortOption = restoredSort
            }
            ensureValidSelection()
        }
        .onChange(of: viewModel.events) { _, _ in
            ensureValidSelection()
        }
        .onChange(of: browserMode) { _, _ in
            dismissSearchAndKeyboard()
            storedBrowserModeRaw = browserMode.rawValue
            ensureValidSelection()
        }
        .onChange(of: selectedEventID) { _, newValue in
            storedSelectedEventID = newValue?.uuidString ?? ""
            ensureValidSelection()
        }
        .onChange(of: searchText) { _, newValue in
            storedSearchText = newValue
        }
        .onChange(of: filterScope) { _, newValue in
            storedFilterScopeRaw = newValue.rawValue
            ensureValidSelection()
        }
        .onChange(of: categoryFilter) { _, newValue in
            storedCategoryFilterRaw = newValue?.rawValue ?? ""
            ensureValidSelection()
        }
        .onChange(of: sortOption) { _, newValue in
            storedSortOptionRaw = newValue.rawValue
            ensureValidSelection()
        }
        .onChange(of: showAddEventSheet) { _, isPresented in
            if isPresented { dismissSearchAndKeyboard() }
        }
        .onChange(of: showTemplateAdd) { _, isPresented in
            if isPresented { dismissSearchAndKeyboard() }
        }
    }

    private var compactView: some View {
        NavigationStack(path: $path) {
            Group {
                if browserMode == .timeline {
                    EventsTimelineView(
                        viewModel: viewModel,
                        externalSearchText: $searchText
                    )
                } else {
                    listContent
                }
            }
            .navigationDestination(for: Event.self) { event in
                EventDetailView(viewModel: viewModel, event: event)
            }
            .toolbarBackground(.regularMaterial, for: .navigationBar)
            .toolbar {
                topToolbar
            }
            .searchable(text: $searchText, isPresented: $isSearchPresented, prompt: "Search title, location, notes, tags")
            .scrollDismissesKeyboard(.immediately)
        }
    }

    private var splitView: some View {
        NavigationSplitView {
            Group {
                if browserMode == .timeline {
                    EventsTimelineView(
                        viewModel: viewModel,
                        selectedEventID: $selectedEventID,
                        useNavigationLinks: false,
                        externalSearchText: $searchText
                    )
                } else {
                    splitListContent
                }
            }
            .searchable(text: $searchText, isPresented: $isSearchPresented, prompt: "Search title, location, notes, tags")
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle("Events")
            .toolbarBackground(.regularMaterial, for: .navigationBar)
            .toolbar {
                topToolbar
            }
        } detail: {
            NavigationStack {
                Group {
                    if let selectedEvent {
                        EventDetailView(viewModel: viewModel, event: selectedEvent)
                    } else {
                        ContentUnavailableView(
                            "Select an event",
                            systemImage: "calendar.badge.clock",
                            description: Text("Choose an item from the left column to open details.")
                        )
                    }
                }
            }
        }
        .navigationSplitViewStyle(.balanced)
    }

    @ToolbarContentBuilder
    private var topToolbar: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Picker("View", selection: $browserMode) {
                ForEach(EventsBrowserMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 280)
        }

        ToolbarItem(placement: .topBarLeading) {
            if !isPadSplitLayout {
                Menu {
                    Section("Filter") {
                        Picker("Filter", selection: $filterScope) {
                            ForEach(EventFilterScope.allCases) { scope in
                                Text(scope.title).tag(scope)
                            }
                        }
                    }

                    Section("Category") {
                        Picker("Category", selection: $categoryFilter) {
                            Text("All categories").tag(Optional<EventCategory>.none)
                            ForEach(EventCategory.allCases, id: \.self) { cat in
                                Text(cat.rawValue).tag(Optional(cat))
                            }
                        }
                    }

                    Section("Sort") {
                        Picker("Sort", selection: $sortOption) {
                            ForEach(EventSortOption.allCases) { option in
                                Text(option.title).tag(option)
                            }
                        }
                    }
                } label: {
                    Label("Filter & sort", systemImage: "line.3.horizontal.decrease.circle")
                }
                .disabled(browserMode == .timeline)
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            HStack(spacing: 8) {
                Menu {
                    Section("New from template") {
                        ForEach(EventTemplate.library) { template in
                            Button(template.title) {
                                templateForAdd = template
                                showTemplateAdd = true
                            }
                        }
                    }
                } label: {
                    Image(systemName: "doc.text.fill")
                        .foregroundStyle(Color.countdownAccent)
                }
                .accessibilityLabel("Templates")

                Button {
                    showAddEventSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, Color.countdownAccent)
                }
                .accessibilityLabel("Add event")
            }
        }
    }

    private var splitListContent: some View {
        List {
            Section("Filters") {
                Picker("Filter", selection: $filterScope) {
                    ForEach(EventFilterScope.allCases) { scope in
                        Text(scope.title).tag(scope)
                    }
                }
                .pickerStyle(.segmented)

                Picker("Category", selection: $categoryFilter) {
                    Text("All categories").tag(Optional<EventCategory>.none)
                    ForEach(EventCategory.allCases, id: \.self) { cat in
                        Text(cat.rawValue).tag(Optional(cat))
                    }
                }
                .pickerStyle(.menu)

                Picker("Sort", selection: $sortOption) {
                    ForEach(EventSortOption.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
                .pickerStyle(.menu)
            }

            Section("Upcoming highlights") {
                if displayedUpcoming.isEmpty {
                    Text("No upcoming events.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(displayedUpcoming) { event in
                        Button {
                            selectedEventID = event.id
                        } label: {
                            EventRow(event: event)
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(splitRowBackground(for: event))
                    }
                }
            }

            Section("All events") {
                if displayedList.isEmpty {
                    Text("No events match your filters.")
                        .foregroundColor(.gray)
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(displayedList) { event in
                        Button {
                            selectedEventID = event.id
                        } label: {
                            EventRow(event: event)
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(splitRowBackground(for: event))
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                viewModel.deleteEvent(event)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }

                            Button {
                                viewModel.toggleFavorite(event)
                            } label: {
                                Label("Favorite", systemImage: "star")
                            }
                            .tint(.countdownAccent)

                            Button {
                                viewModel.duplicateEvent(event)
                            } label: {
                                Label("Duplicate", systemImage: "plus.square.on.square")
                            }
                            .tint(.blue)
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.clear)
    }

    private var listContent: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Events")
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(
                            LinearGradient(colors: [.countdownAccent, Color(red: 1, green: 0.32, blue: 0.05)], startPoint: .leading, endPoint: .trailing)
                        )
                        .shadow(color: Color.countdownAccent.opacity(0.2), radius: 6, y: 2)

                    Text(Self.subtitleFormatter.string(from: Date()))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 4, trailing: 16))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        StatCard(
                            title: "Total events",
                            value: "\(viewModel.events.count)",
                            icon: "calendar",
                            color: .countdownAccent
                        )

                        StatCard(
                            title: "Active",
                            value: "\(viewModel.activeEventsCount)",
                            icon: "calendar.badge.clock",
                            color: .countdownAccent
                        )

                        StatCard(
                            title: "Nearest",
                            value: viewModel.nearestEventTitle,
                            icon: "hourglass",
                            color: .countdownAccent
                        )

                        StatCard(
                            title: "Today",
                            value: "\(viewModel.todayEventsCount)",
                            icon: "star.fill",
                            color: .countdownAccent
                        )
                    }
                    .padding(.vertical, 4)
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Upcoming highlights")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(displayedUpcoming) { event in
                                NavigationLink(value: event) {
                                    EventCard(event: event)
                                }
                                .buttonStyle(.plain)
                            }

                            Button {
                                showAddEventSheet = true
                            } label: {
                                VStack(spacing: 8) {
                                    Image(systemName: "plus.circle.fill")
                                        .symbolRenderingMode(.palette)
                                        .foregroundStyle(.white, Color.countdownAccent)
                                        .font(.largeTitle)
                                    Text("Add")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .frame(width: 140, height: 160)
                                .countdownRaisedCard(cornerRadius: 18, panel: true)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }

            Section {
                Text("All events")
                    .font(.headline)
                    .foregroundColor(.black)
                    .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 4, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }

            Section {
                if displayedList.isEmpty {
                    Text("No events match your filters.")
                        .foregroundColor(.gray)
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(displayedList) { event in
                        NavigationLink(value: event) {
                            EventRow(event: event)
                        }
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                viewModel.deleteEvent(event)
                                path.removeAll { $0.id == event.id }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }

                            Button {
                                viewModel.toggleFavorite(event)
                            } label: {
                                Label("Favorite", systemImage: "star")
                            }
                            .tint(.countdownAccent)

                            Button {
                                viewModel.duplicateEvent(event)
                            } label: {
                                Label("Duplicate", systemImage: "plus.square.on.square")
                            }
                            .tint(.blue)
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.clear)
    }

    private func ensureValidSelection() {
        guard isPadSplitLayout else { return }

        if let selectedEventID,
           viewModel.events.contains(where: { $0.id == selectedEventID }) {
            return
        }

        switch browserMode {
        case .list:
            selectedEventID = displayedList.first?.id ?? displayedUpcoming.first?.id
        case .timeline:
            selectedEventID = viewModel.events
                .sorted { $0.displayDate < $1.displayDate }
                .first?
                .id
        }
    }

    private func splitRowBackground(for event: Event) -> some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(selectedEventID == event.id ? Color.countdownAccent.opacity(0.14) : Color.clear)
            .padding(.vertical, 3)
    }

    private func dismissSearchAndKeyboard() {
        isSearchPresented = false
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
