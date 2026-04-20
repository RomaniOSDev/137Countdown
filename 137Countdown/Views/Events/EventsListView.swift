//
//  EventsListView.swift
//  137Countdown
//

import SwiftUI

struct EventsListView: View {
    @ObservedObject var viewModel: CountdownViewModel

    @State private var path: [Event] = []
    @State private var showAddEventSheet = false

    @State private var searchText = ""
    @State private var filterScope: EventFilterScope = .all
    @State private var categoryFilter: EventCategory?
    @State private var sortOption: EventSortOption = .dateAscending

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
        NavigationStack(path: $path) {
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
            .searchable(text: $searchText, prompt: "Search title, location, notes")
            .toolbarBackground(.regularMaterial, for: .navigationBar)
            .navigationDestination(for: Event.self) { event in
                EventDetailView(viewModel: viewModel, event: event)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
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
                }

                ToolbarItem(placement: .topBarTrailing) {
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
            .sheet(isPresented: $showAddEventSheet) {
                AddEventView(viewModel: viewModel)
            }
        }
    }
}
