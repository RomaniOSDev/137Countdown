//
//  CompletedView.swift
//  137Countdown
//

import SwiftUI

struct CompletedView: View {
    @ObservedObject var viewModel: CountdownViewModel

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Event archive")
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(
                            LinearGradient(colors: [.countdownAccent, Color(red: 1, green: 0.32, blue: 0.05)], startPoint: .leading, endPoint: .trailing)
                        )
                        .shadow(color: Color.countdownAccent.opacity(0.15), radius: 4, y: 2)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }

                if viewModel.completedEvents.isEmpty {
                    Section {
                        Text("No archived events yet.")
                            .foregroundColor(.gray)
                            .listRowBackground(Color.clear)
                    }
                } else {
                    Section {
                        ForEach(viewModel.completedEvents) { event in
                            CompletedEventCard(event: event)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        viewModel.deleteCompletedEvent(event)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }

                                    Button {
                                        viewModel.restoreEvent(event)
                                    } label: {
                                        Label("Restore", systemImage: "arrow.uturn.backward")
                                    }
                                    .tint(.countdownAccent)
                                }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .toolbarBackground(.regularMaterial, for: .navigationBar)
        }
    }
}
