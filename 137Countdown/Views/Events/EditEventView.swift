//
//  EditEventView.swift
//  137Countdown
//

import SwiftUI

struct EditEventView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CountdownViewModel

    private let eventId: UUID
    @State private var title = ""
    @State private var date = Date()
    @State private var category: EventCategory = .other
    @State private var location = ""
    @State private var notes = ""
    @State private var reminderType: ReminderType = .none
    @State private var customReminderDays = 1
    @State private var isFavorite = false
    @State private var colorTag: EventColorTag = .none
    @State private var recurrenceRule: RecurrenceRule = .none
    @State private var tagsRaw = ""
    @State private var milestoneCheckpointsEnabled = true
    @State private var pinAsSpotlight = false
    @State private var countMode: EventCountMode = .countdown
    @State private var emotion: EventMood = .neutral
    @State private var goal = ""
    @State private var customMilestonesRaw = ""

    init(viewModel: CountdownViewModel, event: Event) {
        self.viewModel = viewModel
        eventId = event.id
        _title = State(initialValue: event.title)
        _date = State(initialValue: event.date)
        _category = State(initialValue: event.category)
        _location = State(initialValue: event.location ?? "")
        _notes = State(initialValue: event.notes ?? "")
        _reminderType = State(initialValue: event.reminder)
        _customReminderDays = State(initialValue: event.customReminderDays ?? 1)
        _isFavorite = State(initialValue: event.isFavorite)
        _colorTag = State(initialValue: event.colorTag)
        _recurrenceRule = State(initialValue: event.recurrenceRule)
        _tagsRaw = State(initialValue: EventTagsParser.displayString(from: event.tags))
        _milestoneCheckpointsEnabled = State(initialValue: event.milestoneCheckpointsEnabled)
        _pinAsSpotlight = State(initialValue: event.isSpotlight)
        _countMode = State(initialValue: event.countMode)
        _emotion = State(initialValue: event.emotion)
        _goal = State(initialValue: event.goal ?? "")
        _customMilestonesRaw = State(initialValue: event.customMilestoneDays.map(String.init).joined(separator: ","))
    }

    private var trimmedTitle: String { title.trimmingCharacters(in: .whitespacesAndNewlines) }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Event title", text: $title)
                    DatePicker("Date & time", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    Picker("Count mode", selection: $countMode) {
                        ForEach(EventCountMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    Picker("Category", selection: $category) {
                        ForEach(EventCategory.allCases, id: \.self) { cat in
                            Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                        }
                    }
                }
                Section("Emotion mode") {
                    Picker("Mood", selection: $emotion) {
                        ForEach(EventMood.allCases) { mood in
                            Label(mood.rawValue, systemImage: mood.symbol).tag(mood)
                        }
                    }
                    TextField("Goal", text: $goal, axis: .vertical)
                }
                Section("Tags & milestones") {
                    TextField("Tags (comma-separated)", text: $tagsRaw)
                    Toggle("Enable 30 / 7 / 1 milestones", isOn: $milestoneCheckpointsEnabled)
                    TextField("Custom milestones in days", text: $customMilestonesRaw)
                }
                Section("Details") {
                    TextField("Location", text: $location)
                    TextEditor(text: $notes).frame(height: 90)
                }
                Section("Reminder") {
                    Picker("Remind me", selection: $reminderType) {
                        ForEach(ReminderType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    if reminderType == .custom {
                        Stepper("Days before: \(customReminderDays)", value: $customReminderDays, in: 1 ... 365)
                    }
                }
                Section("Appearance") {
                    Picker("Color tag", selection: $colorTag) {
                        ForEach(EventColorTag.allCases, id: \.self) { tag in
                            Text(tag.displayName).tag(tag)
                        }
                    }
                    Picker("Recurrence", selection: $recurrenceRule) {
                        ForEach(RecurrenceRule.allCases, id: \.self) { rule in
                            Text(rule.displayName).tag(rule)
                        }
                    }
                }
                Section {
                    Toggle("Add to favorites", isOn: $isFavorite)
                    Toggle("Pin as main event on Home", isOn: $pinAsSpotlight)
                }
            }
            .navigationTitle("Edit event")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }.disabled(trimmedTitle.isEmpty)
                }
            }
        }
    }

    private func save() {
        guard let existing = viewModel.events.first(where: { $0.id == eventId }) else {
            dismiss()
            return
        }
        let updated = Event(
            id: existing.id,
            title: trimmedTitle,
            date: date,
            category: category,
            notes: notes.isEmpty ? nil : notes,
            location: location.isEmpty ? nil : location,
            reminder: reminderType,
            customReminderDays: reminderType == .custom ? customReminderDays : nil,
            imageName: existing.imageName,
            isFavorite: isFavorite,
            createdAt: existing.createdAt,
            colorTag: colorTag,
            recurrenceRule: recurrenceRule,
            isSpotlight: pinAsSpotlight,
            tags: EventTagsParser.parse(tagsRaw),
            milestoneCheckpointsEnabled: milestoneCheckpointsEnabled,
            countMode: countMode,
            emotion: emotion,
            goal: goal.isEmpty ? nil : goal,
            stories: existing.stories,
            customMilestoneDays: customMilestonesRaw
                .split(separator: ",")
                .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
                .filter { $0 > 0 }
        )
        viewModel.updateEvent(updated)
        dismiss()
    }
}
