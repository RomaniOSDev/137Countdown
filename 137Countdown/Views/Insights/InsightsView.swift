//
//  InsightsView.swift
//  137Countdown
//

import SwiftUI

struct InsightsView: View {
    @ObservedObject var viewModel: CountdownViewModel

    private var countdownCount: Int { viewModel.events.filter { $0.countMode == .countdown }.count }
    private var countUpCount: Int { viewModel.events.filter { $0.countMode == .countUp }.count }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    metricCard(title: "Total events", value: "\(viewModel.events.count)", icon: "calendar")
                    metricCard(title: "Countdown / Count-up", value: "\(countdownCount) / \(countUpCount)", icon: "arrow.left.arrow.right")
                    metricCard(title: "Stories per event", value: String(format: "%.1f", viewModel.averageStoriesPerEvent), icon: "text.bubble")
                    metricCard(title: "Pinned main event", value: viewModel.events.contains(where: { $0.isSpotlight }) ? "Yes" : "No", icon: "pin.fill")

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Mood distribution").font(.headline)
                        ForEach(viewModel.moodDistribution, id: \.0) { mood, count in
                            HStack {
                                Label(mood.rawValue, systemImage: mood.symbol)
                                Spacer()
                                Text("\(count)")
                            }
                        }
                    }
                    .padding(14)
                    .countdownRaisedCard(cornerRadius: 16, panel: true)
                }
                .padding(16)
            }
            .navigationTitle("Insights")
        }
    }

    @ViewBuilder
    private func metricCard(title: String, value: String, icon: String) -> some View {
        HStack {
            Label(title, systemImage: icon)
            Spacer()
            Text(value).font(.headline)
        }
        .padding(14)
        .countdownRaisedCard(cornerRadius: 16, panel: true)
    }
}
