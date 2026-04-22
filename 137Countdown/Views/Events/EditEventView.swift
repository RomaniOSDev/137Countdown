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

    init(viewModel: CountdownViewModel, event: Event) {
        self.viewModel = viewModel
        self.eventId = event.id
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
    }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                CountdownScreenBackground()

                Form {
                    Section {
                        TextField("Event title", text: $title)
                            .foregroundColor(.black)
                            .tint(.countdownAccent)

                        DatePicker("Date & time", selection: $date, displayedComponents: [.date, .hourAndMinute])
                            .tint(.countdownAccent)

                        Picker("Category", selection: $category) {
                            ForEach(EventCategory.allCases, id: \.self) { cat in
                                Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                            }
                        }
                        .tint(.countdownAccent)
                    }

                    Section(header: Text("Tags").foregroundColor(.gray)) {
                        TextField("Comma-separated", text: $tagsRaw)
                            .foregroundColor(.black)
                            .tint(.countdownAccent)
                    }

                    Section(header: Text("Color tag").foregroundColor(.gray)) {
                        Picker("Tag color", selection: $colorTag) {
                            ForEach(EventColorTag.allCases, id: \.self) { tag in
                                HStack {
                                    Circle()
                                        .fill(tag == .none ? Color.countdownAccent : tag.stripeColor)
                                        .frame(width: 12, height: 12)
                                    Text(tag.displayName)
                                }
                                .tag(tag)
                            }
                        }
                        .tint(.countdownAccent)
                    }

                    Section(header: Text("Repeat").foregroundColor(.gray)) {
                        Picker("Recurrence", selection: $recurrenceRule) {
                            ForEach(RecurrenceRule.allCases, id: \.self) { rule in
                                Text(rule.displayName).tag(rule)
                            }
                        }
                        .tint(.countdownAccent)
                    }

                    Section(header: Text("Details").foregroundColor(.gray)) {
                        TextField("Location", text: $location)
                            .foregroundColor(.black)
                            .tint(.countdownAccent)

                        TextEditor(text: $notes)
                            .frame(height: 80)
                            .foregroundColor(.black)
                            .tint(.countdownAccent)
                    }

                    Section(header: Text("Reminder").foregroundColor(.gray)) {
                        Picker("Remind me", selection: $reminderType) {
                            ForEach(ReminderType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .tint(.countdownAccent)

                        if reminderType == .custom {
                            HStack {
                                Text("Days before")
                                Spacer()
                                Stepper("\(customReminderDays)", value: $customReminderDays, in: 1 ... 365)
                                    .tint(.countdownAccent)
                            }
                        }
                    }

                    Section(header: Text("Milestones").foregroundColor(.gray)) {
                        Toggle("30 / 7 / 1 day checkpoints", isOn: $milestoneCheckpointsEnabled)
                            .tint(.countdownAccent)
                    }

                    Section {
                        Toggle("Add to favorites", isOn: $isFavorite)
                            .tint(.countdownAccent)
                        Toggle("Pin as main event on Home", isOn: $pinAsSpotlight)
                            .tint(.countdownAccent)
                    }
                }
                .foregroundColor(.black)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Edit event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.regularMaterial, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.countdownAccent)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(trimmedTitle.isEmpty ? .gray : .countdownAccent)
                    .disabled(trimmedTitle.isEmpty)
                }
            }
        }
    }

    private func save() {
        guard let existing = viewModel.events.first(where: { $0.id == eventId }) else {
            dismiss()
            return
        }
        let parsedTags = EventTagsParser.parse(tagsRaw)
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
            tags: parsedTags,
            milestoneCheckpointsEnabled: milestoneCheckpointsEnabled
        )
        viewModel.updateEvent(updated)
        dismiss()
    }
}
