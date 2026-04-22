//
//  OnboardingView.swift
//  137Countdown
//

import SwiftUI

struct OnboardingView: View {
    var onFinish: () -> Void

    @State private var page = 0

    private let pages: [(title: String, subtitle: String, symbol: String)] = [
        (
            "Plan what matters",
            "Start from templates or build your own countdown. Pin one main event on Home, add tags, and set milestone alerts at 30, 7, and 1 day before.",
            "calendar.badge.clock"
        ),
        (
            "See the full story",
            "Switch between List and Timeline to mix upcoming dates with recent completions. Filter by category, search tags, and export a beautiful share card or a calendar file.",
            "calendar.day.timeline.left"
        ),
        (
            "Make it yours",
            "Favorite moments, archive past events, and collect quotes — stored privately on your device with optional local notifications.",
            "sparkles"
        )
    ]

    var body: some View {
        ZStack {
            CountdownScreenBackground()

            VStack(spacing: 0) {
                TabView(selection: $page) {
                    ForEach(pages.indices, id: \.self) { index in
                        pageContent(index: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))

                bottomBar
                    .padding(.horizontal, 22)
                    .padding(.bottom, 28)
                    .padding(.top, 12)
            }
        }
    }

    private func pageContent(index: Int) -> some View {
        let item = pages[index]

        return VStack(spacing: 28) {
            Spacer(minLength: 24)

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.countdownAccent.opacity(0.35), Color.countdownAccent.opacity(0.08), Color.clear],
                            center: .center,
                            startRadius: 8,
                            endRadius: 88
                        )
                    )
                    .frame(width: 160, height: 160)
                    .shadow(color: Color.countdownAccent.opacity(0.25), radius: 20, y: 10)

                Image(systemName: item.symbol)
                    .font(.system(size: 64, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.countdownAccent, Color(red: 1, green: 0.32, blue: 0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .symbolRenderingMode(.hierarchical)
            }

            VStack(spacing: 14) {
                Text(item.title)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)

                Text(item.subtitle)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 8)
            }

            Spacer(minLength: 120)
        }
        .padding(.horizontal, 20)
    }

    private var bottomBar: some View {
        HStack(spacing: 14) {
            Button("Skip") {
                onFinish()
            }
            .font(.body.weight(.medium))
            .foregroundColor(.countdownAccent)

            Spacer()

            if page < pages.count - 1 {
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        page += 1
                    }
                } label: {
                    Text("Next")
                        .font(.body.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(CountdownVisual.primaryButton)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(CountdownVisual.primaryButtonStroke, lineWidth: 1)
                        )
                        .shadow(color: Color.countdownAccent.opacity(0.35), radius: 12, x: 0, y: 6)
                }
            } else {
                Button {
                    onFinish()
                } label: {
                    Text("Get started")
                        .font(.body.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(CountdownVisual.primaryButton)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(CountdownVisual.primaryButtonStroke, lineWidth: 1)
                        )
                        .shadow(color: Color.countdownAccent.opacity(0.38), radius: 14, x: 0, y: 6)
                }
            }
        }
    }
}

#Preview {
    OnboardingView(onFinish: {})
}
