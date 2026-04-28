//
//  EventDetailView.swift
//  137Countdown
//

import SwiftUI
import PhotosUI
import UIKit

struct EventDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CountdownViewModel
    private let eventId: UUID

    @State private var showEditSheet = false
    @State private var showDeleteConfirmation = false
    @State private var showShareSheet = false
    @State private var shareItems: [Any] = []
    @State private var newStoryNote = ""
    @State private var showPhotoPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var pendingStoryImageReference: String?

    init(viewModel: CountdownViewModel, event: Event) {
        self.viewModel = viewModel
        eventId = event.id
    }

    private var event: Event? { viewModel.events.first { $0.id == eventId } }
    private var canAddStory: Bool {
        !newStoryNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || pendingStoryImageReference != nil
    }

    var body: some View {
        Group {
            if let event {
                ScrollView {
                    VStack(spacing: 16) {
                        EventShareCardView(event: event)
                        moodGoalSection(event)
                        milestoneTimelineSection(event)
                        storiesSection(event)
                        shareSection(event)
                        actionSection(event)
                    }
                    .padding(.bottom, 24)
                }
                .scrollDismissesKeyboard(.immediately)
                .navigationTitle(event.title)
                .navigationBarTitleDisplayMode(.inline)
                .sheet(isPresented: $showEditSheet) { EditEventView(viewModel: viewModel, event: event) }
                .sheet(isPresented: $showShareSheet) { ActivityShareSheet(items: shareItems) }
                .photosPicker(isPresented: $showPhotoPicker, selection: $selectedPhotoItem, matching: .images)
                .safeAreaInset(edge: .bottom) {
                    storyComposer
                }
                .alert("Delete this event?", isPresented: $showDeleteConfirmation) {
                    Button("Delete", role: .destructive) {
                        viewModel.deleteEvent(event)
                        dismiss()
                    }
                    Button("Cancel", role: .cancel) {}
                }
            } else {
                ProgressView().onAppear { dismiss() }
            }
        }
    }

    @ViewBuilder
    private func moodGoalSection(_ event: Event) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Emotion mode", systemImage: event.emotion.symbol).font(.headline)
            Text("Mood: \(event.emotion.rawValue)")
            if let goal = event.goal, !goal.isEmpty {
                Text("Goal: \(goal)")
            }
            Text(event.statusText).foregroundColor(.secondary)
        }
        .padding(16)
        .countdownRaisedCard(cornerRadius: 16, panel: true)
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func milestoneTimelineSection(_ event: Event) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Milestones timeline").font(.headline)
            ForEach(event.milestoneDays, id: \.self) { day in
                let reached = event.isPast ? abs(event.daysLeft) >= day : event.daysLeft <= day
                HStack {
                    Image(systemName: reached ? "checkmark.seal.fill" : "circle")
                        .foregroundColor(reached ? .countdownAccent : .secondary)
                    Text(day == 1 ? "1 day mark" : "\(day) day mark")
                    Spacer()
                    Text(reached ? motivationalLine(for: event.emotion) : "Ahead")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .countdownRaisedCard(cornerRadius: 16, panel: true)
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func storiesSection(_ event: Event) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Countdown stories").font(.headline)
            if event.stories.isEmpty {
                Text("No stories yet. Add notes about your progress.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(event.stories) { story in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(story.date, style: .date).font(.caption).foregroundColor(.secondary)
                        Text(story.note)
                        if let imageReference = story.imageReference, !imageReference.isEmpty {
                            if let image = imageFromLocalReference(imageReference) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 160)
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            } else {
                                Label("Photo unavailable", systemImage: "photo.slash")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            HStack {
                Text("Use the composer at the bottom to add a story.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            if let pendingStoryImageReference, let preview = imageFromLocalReference(pendingStoryImageReference) {
                Image(uiImage: preview)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }
        .padding(16)
        .countdownRaisedCard(cornerRadius: 16, panel: true)
        .padding(.horizontal, 16)
        .onChange(of: selectedPhotoItem) { _, newValue in
            print("DEBUG selectedPhotoItem changed hasValue=\(newValue != nil)")
            guard let newValue else { return }
            Task { await loadSelectedPhoto(newValue) }
        }
        .onChange(of: newStoryNote) { _, newValue in
            let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
            print("DEBUG newStoryNote changed trimmedCount=\(trimmed.count) canAddStory=\(canAddStory)")
        }
    }

    @ViewBuilder
    private func shareSection(_ event: Event) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Share & export").font(.headline)
            Button("Share countdown card") {
                if let image = EventShareImageRenderer.renderPNG(event: event) {
                    shareItems = [image]
                    showShareSheet = true
                }
            }
            ShareLink(item: "“\(event.title)” — \(event.statusText)") { Label("Share as text", systemImage: "text.alignleft") }
            if let url = temporaryICSFileURL(for: event) {
                ShareLink(item: url) { Label("Export calendar (.ics)", systemImage: "calendar.badge.plus") }
            }
        }
        .padding(16)
        .countdownRaisedCard(cornerRadius: 16, panel: true)
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func actionSection(_ event: Event) -> some View {
        HStack(spacing: 12) {
            Button("Edit") { showEditSheet = true }
                .buttonStyle(.borderedProminent)
            Button(event.isSpotlight ? "Unpin" : "Pin") {
                viewModel.setSpotlight(event.isSpotlight ? nil : event)
            }
            .buttonStyle(.bordered)
            Button("Delete", role: .destructive) { showDeleteConfirmation = true }
                .buttonStyle(.bordered)
        }
        .padding(.horizontal, 16)
    }

    private func addStory() {
        print("DEBUG addStory entered")
        guard let event else { return }
        let note = newStoryNote.trimmingCharacters(in: .whitespacesAndNewlines)
        print("DEBUG addStory noteEmpty=\(note.isEmpty) hasImage=\(pendingStoryImageReference != nil)")
        guard !note.isEmpty || pendingStoryImageReference != nil else { return }
        var updated = event
        let finalNote = note.isEmpty ? "Photo update" : note
        print("DEBUG addStory inserting story finalNote=\(finalNote)")
        updated.stories.insert(EventStoryEntry(note: finalNote, imageReference: pendingStoryImageReference), at: 0)
        viewModel.updateEvent(updated)
        print("DEBUG addStory updateEvent completed")
        newStoryNote = ""
        pendingStoryImageReference = nil
        selectedPhotoItem = nil
    }

    private var storyComposer: some View {
        VStack(spacing: 8) {
            if let pendingStoryImageReference, let preview = imageFromLocalReference(pendingStoryImageReference) {
                Image(uiImage: preview)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            HStack {
                TextField("Add story note", text: $newStoryNote)
                    .textFieldStyle(.roundedBorder)
                Button {
                    showPhotoPicker = true
                } label: {
                    Image(systemName: pendingStoryImageReference == nil ? "photo.badge.plus" : "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.countdownAccent)
                }
                Button {
                    print("DEBUG Add button action tapped")
                    print("DEBUG canAddStory=\(canAddStory) noteEmpty=\(newStoryNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) hasImage=\(pendingStoryImageReference != nil)")
                    dismissKeyboard()
                    addStory()
                } label: {
                    Text("Add")
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canAddStory)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }

    private func motivationalLine(for mood: EventMood) -> String {
        switch mood {
        case .neutral: return "Stay steady"
        case .excited: return "Keep momentum"
        case .focused: return "Lock in"
        case .grateful: return "Appreciate progress"
        case .ambitious: return "Push forward"
        }
    }

    private func temporaryICSFileURL(for event: Event) -> URL? {
        let ics = EventCalendarExport.icsDocument(for: event)
        let safe = event.title.replacingOccurrences(of: "/", with: "-")
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(safe)-countdown.ics")
        guard let data = ics.data(using: .utf8) else { return nil }
        do { try data.write(to: url, options: .atomic); return url } catch { return nil }
    }

    private func imageFromLocalReference(_ reference: String) -> UIImage? {
        UIImage(contentsOfFile: reference)
    }

    @MainActor
    private func loadSelectedPhoto(_ item: PhotosPickerItem) async {
        do {
            guard let data = try await item.loadTransferable(type: Data.self) else { return }
            pendingStoryImageReference = try saveStoryImageToDisk(data: data)
        } catch {
            pendingStoryImageReference = nil
        }
    }

    private func saveStoryImageToDisk(data: Data) throws -> String {
        let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("StoryImages", isDirectory: true)
        if !FileManager.default.fileExists(atPath: folder.path) {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        let fileURL = folder.appendingPathComponent("\(UUID().uuidString).img")
        try data.write(to: fileURL, options: .atomic)
        return fileURL.path
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
