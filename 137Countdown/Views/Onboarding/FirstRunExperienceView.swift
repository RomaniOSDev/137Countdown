//
//  FirstRunExperienceView.swift
//  137Countdown
//

import SwiftUI

struct FirstRunExperienceView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CountdownViewModel

    @State private var selectedTemplate: EventTemplate?
    @State private var showTemplateAdd = false
    @State private var showBlankAdd = false

    var body: some View {
        NavigationStack {
            ZStack {
                CountdownScreenBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        Text("Welcome")
                            .font(.largeTitle.bold())
                            .foregroundColor(.black)

                        Text("Pin a main event on Home, use templates, milestones, and the timeline — or start with sample data.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Start from a template")
                                .font(.headline)
                                .foregroundColor(.black)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(EventTemplate.library) { template in
                                    Button {
                                        selectedTemplate = template
                                        showTemplateAdd = true
                                    } label: {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Image(systemName: template.symbolName)
                                                .font(.title2)
                                                .foregroundColor(.countdownAccent)
                                            Text(template.title)
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundColor(.black)
                                                .lineLimit(2)
                                                .multilineTextAlignment(.leading)
                                            Text(template.subtitle)
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(14)
                                        .countdownRaisedCard(cornerRadius: 16, panel: false)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        Button {
                            showBlankAdd = true
                        } label: {
                            Text("Create blank event")
                                .font(.body.weight(.semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(CountdownVisual.primaryButton)
                                )
                        }

                        Button {
                            viewModel.loadDemoDataForFirstRun()
                            finish()
                        } label: {
                            Text("Explore with sample events")
                                .font(.body.weight(.semibold))
                                .foregroundColor(.countdownAccent)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .strokeBorder(Color.countdownAccent.opacity(0.45), lineWidth: 1.5)
                                )
                        }

                        Button {
                            finish()
                        } label: {
                            Text("Skip for now")
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                        }
                        .padding(.top, 4)
                    }
                    .padding(22)
                    .padding(.bottom, 32)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { finish() }
                        .foregroundColor(.countdownAccent)
                }
            }
            .sheet(isPresented: $showTemplateAdd, onDismiss: { selectedTemplate = nil }) {
                AddEventView(viewModel: viewModel, template: selectedTemplate, onFinished: finish)
            }
            .sheet(isPresented: $showBlankAdd) {
                AddEventView(viewModel: viewModel, template: nil, onFinished: finish)
            }
        }
    }

    private func finish() {
        UserDefaults.standard.set(true, forKey: CountdownViewModel.firstExperienceCompletedKey)
        dismiss()
    }
}
