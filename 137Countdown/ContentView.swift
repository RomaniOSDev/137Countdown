//
//  ContentView.swift
//  137Countdown
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    @StateObject private var viewModel = CountdownViewModel()
    @State private var selectedTab = 0
    @AppStorage(CountdownViewModel.firstExperienceCompletedKey) private var firstExperienceCompleted = false
    @State private var showFirstRunExperience = false

    var body: some View {
        ZStack {
            CountdownScreenBackground()

            TabView(selection: $selectedTab) {
            HomeView(viewModel: viewModel, selectedTab: $selectedTab)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            EventsListView(viewModel: viewModel)
                .tabItem {
                    Label("Events", systemImage: "calendar")
                }
                .tag(1)

            CalendarView(viewModel: viewModel)
                .tabItem {
                    Label("Calendar", systemImage: "calendar.day.timeline.left")
                }
                .tag(2)

            QuotesView(viewModel: viewModel)
                .tabItem {
                    Label("Inspiration", systemImage: "quote.opening")
                }
                .tag(3)

            InsightsView(viewModel: viewModel)
                .tabItem {
                    Label("Insights", systemImage: "chart.bar.fill")
                }
                .tag(4)

            CompletedView(viewModel: viewModel)
                .tabItem {
                    Label("Archive", systemImage: "archivebox.fill")
                }
                .tag(5)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(6)
            }
        }
        .tint(.countdownAccent)
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
        .onAppear {
            viewModel.loadFromUserDefaults()
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
            if !firstExperienceCompleted && viewModel.events.isEmpty {
                showFirstRunExperience = true
            }
        }
        .sheet(isPresented: $showFirstRunExperience, onDismiss: {
            showFirstRunExperience = false
            if !firstExperienceCompleted && viewModel.events.isEmpty {
                UserDefaults.standard.set(true, forKey: CountdownViewModel.firstExperienceCompletedKey)
            }
        }) {
            FirstRunExperienceView(viewModel: viewModel)
        }
    }
}

#Preview {
    ContentView()
}
