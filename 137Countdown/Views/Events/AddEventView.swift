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

    init(viewModel: CountdownViewModel, template: EventTemplate? = nil, onFinished: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.template = template
        self.onFinished = onFinished
    }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                CountdownScreenBackground()

                Form {
                    if template != nil {
                        Section {
                            Label("Prefilled from template — adjust as you like.", systemImage: "doc.text.fill")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }

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
                        TextField("e.g. family, work, trip", text: $tagsRaw)
                            .foregroundColor(.black)
                            .tint(.countdownAccent)
                        Text("Comma-separated. Used for search.")
                            .font(.caption)
                            .foregroundColor(.secondary)
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
                        Text("Optional local notifications at 9:00 on those milestone days.")
                            .font(.caption)
                            .foregroundColor(.secondary)
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
            .navigationTitle("New event")
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
            .onAppear {
                applyTemplateIfNeeded()
            }
        }
    }

    private func applyTemplateIfNeeded() {
        guard let t = template else { return }
        title = t.title
        date = t.suggestedDate()
        category = t.category
        notes = t.notes ?? ""
        reminderType = t.reminder
        if t.reminder == .custom {
            customReminderDays = t.customReminderDays ?? 7
        }
        colorTag = t.colorTag
        recurrenceRule = t.recurrenceRule
        tagsRaw = EventTagsParser.displayString(from: t.defaultTags)
    }

    private func save() {
        let parsedTags = EventTagsParser.parse(tagsRaw)
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
            tags: parsedTags,
            milestoneCheckpointsEnabled: milestoneCheckpointsEnabled
        )
        viewModel.addEvent(event)
        onFinished?()
        dismiss()
    }
}
