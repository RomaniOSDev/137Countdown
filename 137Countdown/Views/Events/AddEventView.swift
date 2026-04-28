//
//  AddEventView.swift
//  137Countdown
//

import SwiftUI

struct AddEventView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CountdownViewModel

    private let template: EventTemplate?
    private let onFinished: (() -> Void)?

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

    init(viewModel: CountdownViewModel, template: EventTemplate? = nil, onFinished: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.template = template
        self.onFinished = onFinished
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
                    TextField("Custom milestones in days (e.g. 90,60,10)", text: $customMilestonesRaw)
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
            .navigationTitle("New event")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }.disabled(trimmedTitle.isEmpty)
                }
            }
            .onAppear { applyTemplateIfNeeded() }
        }
    }

    private func applyTemplateIfNeeded() {
        guard let t = template else { return }
        title = t.title
        date = t.suggestedDate()
        category = t.category
        notes = t.notes ?? ""
        reminderType = t.reminder
        customReminderDays = t.customReminderDays ?? 7
        colorTag = t.colorTag
        recurrenceRule = t.recurrenceRule
        tagsRaw = EventTagsParser.displayString(from: t.defaultTags)
        countMode = t.countMode
        emotion = t.defaultMood
        goal = t.defaultGoal ?? ""
        customMilestonesRaw = t.defaultMilestones.map(String.init).joined(separator: ",")
    }

    private func save() {
        let event = Event(
            id: UUID(),
            title: trimmedTitle,
            date: date,
            category: category,
            notes: notes.isEmpty ? nil : notes,
            location: location.isEmpty ? nil : location,
            reminder: reminderType,
            customReminderDays: reminderType == .custom ? customReminderDays : nil,
            imageName: nil,
            isFavorite: isFavorite,
            createdAt: Date(),
            colorTag: colorTag,
            recurrenceRule: recurrenceRule,
            isSpotlight: pinAsSpotlight,
            tags: EventTagsParser.parse(tagsRaw),
            milestoneCheckpointsEnabled: milestoneCheckpointsEnabled,
            countMode: countMode,
            emotion: emotion,
            goal: goal.isEmpty ? nil : goal,
            stories: [],
            customMilestoneDays: customMilestonesRaw
                .split(separator: ",")
                .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
                .filter { $0 > 0 }
        )
        viewModel.addEvent(event)
        onFinished?()
        dismiss()
    }
}
