//
//  EventDetailView.swift
//  137Countdown
//

import SwiftUI

struct EventDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CountdownViewModel

    private let eventId: UUID

    @State private var showEditSheet = false
    @State private var showDeleteConfirmation = false

    init(viewModel: CountdownViewModel, event: Event) {
        self.viewModel = viewModel
        self.eventId = event.id
    }

    private var event: Event? {
        viewModel.events.first { $0.id == eventId }
    }

    var body: some View {
        Group {
            if let event {
                ScrollView {
                    VStack(spacing: 20) {
                        header(event)
                        details(event)
                        actions(event)
                    }
                    .padding(.bottom, 28)
                }
                .background(Color.clear)
                .navigationTitle(event.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.regularMaterial, for: .navigationBar)
                .sheet(isPresented: $showEditSheet) {
                    EditEventView(viewModel: viewModel, event: event)
                }
                .alert("Delete this event?", isPresented: $showDeleteConfirmation) {
                    Button("Delete", role: .destructive) {
                        viewModel.deleteEvent(event)
                        dismiss()
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("It will be moved to the archive.")
                }
            } else {
                ProgressView()
                    .onAppear { dismiss() }
            }
        }
    }

    @ViewBuilder
    private func header(_ event: Event) -> some View {
        let accent = event.colorTag == .none ? Color.countdownAccent : event.colorTag.stripeColor

        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            accent.opacity(0.14),
                            Color.white,
                            Color(red: 0.97, green: 0.98, blue: 1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .strokeBorder(CountdownVisual.cardStroke, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.08), radius: 24, x: 0, y: 14)
                .shadow(color: accent.opacity(0.12), radius: 20, x: 0, y: 8)

            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [accent.opacity(0.35), accent.opacity(0.08)],
                                center: .center,
                                startRadius: 4,
                                endRadius: 48
                            )
                        )
                        .frame(width: 96, height: 96)
                        .shadow(color: accent.opacity(0.25), radius: 12, y: 4)

                    Image(systemName: event.category.icon)
                        .foregroundStyle(
                            LinearGradient(colors: [accent, accent.opacity(0.75)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .font(.system(size: 52))
                }

                Text(event.title)
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)

                Text(event.formattedDateTime)
                    .font(.headline)
                    .foregroundColor(.gray)

                if event.isPast {
                    Text(event.statusText)
                        .font(.title)
                        .foregroundColor(.gray)
                } else if event.isToday {
                    Text("TODAY!")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(colors: [.countdownAccent, Color(red: 1, green: 0.32, blue: 0.05)], startPoint: .leading, endPoint: .trailing)
                        )
                        .shadow(color: Color.countdownAccent.opacity(0.25), radius: 8, y: 4)
                } else {
                    Text("\(event.daysLeft)")
                        .font(.system(size: 72, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(colors: [.countdownAccent, Color(red: 1, green: 0.3, blue: 0.02)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .shadow(color: Color.countdownAccent.opacity(0.22), radius: 10, y: 6)

                    Text(event.daysUnitDetail)
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            .padding(24)
        }
        .padding(.horizontal, 4)
    }

    @ViewBuilder
    private func details(_ event: Event) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "paintpalette.fill")
                    .foregroundStyle(
                        LinearGradient(colors: [.countdownAccent, .countdownAccent.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                    )
                    .frame(width: 24)
                HStack(spacing: 8) {
                    Circle()
                        .fill(event.colorTag == .none ? Color.gray.opacity(0.35) : event.colorTag.stripeColor)
                        .frame(width: 14, height: 14)
                        .shadow(color: (event.colorTag == .none ? Color.gray : event.colorTag.stripeColor).opacity(0.35), radius: 3, y: 1)
                    Text(event.colorTag.displayName)
                        .foregroundColor(.black)
                }
            }

            if event.recurrenceRule != .none {
                HStack(alignment: .top) {
                    Image(systemName: "repeat")
                        .foregroundColor(.countdownAccent)
                        .frame(width: 24)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(event.recurrenceRule.displayName)
                            .foregroundColor(.black)
                        Text("Anchor: \(DateFormatting.mediumDateTime.string(from: event.date))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }

            if let location = event.location, !location.isEmpty {
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.countdownAccent)
                        .frame(width: 24)
                    Text(location)
                        .foregroundColor(.black)
                }
            }

            if let notes = event.notes, !notes.isEmpty {
                HStack(alignment: .top) {
                    Image(systemName: "note.text")
                        .foregroundColor(.countdownAccent)
                        .frame(width: 24)
                    Text(notes)
                        .foregroundColor(.black)
                }
            }

            HStack {
                Image(systemName: "bell.fill")
                    .foregroundColor(.countdownAccent)
                    .frame(width: 24)
                Text(event.reminder.rawValue)
                    .foregroundColor(.black)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .countdownRaisedCard(cornerRadius: 20, panel: true)
        .padding(.horizontal, 4)
    }

    @ViewBuilder
    private func actions(_ event: Event) -> some View {
        HStack(spacing: 14) {
            Button("Edit") {
                showEditSheet = true
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(CountdownVisual.primaryButton)
                    .shadow(color: Color.countdownAccent.opacity(0.4), radius: 12, x: 0, y: 6)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(CountdownVisual.primaryButtonStroke, lineWidth: 1)
            )
            .foregroundColor(.white)
            .font(.body.weight(.semibold))

            Button("Delete") {
                showDeleteConfirmation = true
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(CountdownVisual.cardFill)
                    .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color.countdownAccent.opacity(0.55), Color.countdownAccent.opacity(0.25)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .foregroundColor(.countdownAccent)
            .font(.body.weight(.semibold))
        }
        .padding(.horizontal, 4)
    }
}
