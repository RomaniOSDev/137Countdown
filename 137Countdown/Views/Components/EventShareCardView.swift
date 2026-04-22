//
//  EventShareCardView.swift
//  137Countdown
//

import SwiftUI
import UIKit

/// Card layout for sharing as image or preview.
struct EventShareCardView: View {
    let event: Event

    private var accent: Color {
        event.colorTag == .none ? Color.countdownAccent : event.colorTag.stripeColor
    }

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: event.category.icon)
                .font(.system(size: 44))
                .foregroundStyle(
                    LinearGradient(colors: [accent, accent.opacity(0.75)], startPoint: .topLeading, endPoint: .bottomTrailing)
                )

            Text(event.title)
                .font(.title2.weight(.bold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(3)

            if event.isPast {
                Text(event.statusText)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.secondary)
            } else if event.isToday {
                Text("Today!")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(colors: [.countdownAccent, Color(red: 1, green: 0.32, blue: 0.05)], startPoint: .leading, endPoint: .trailing)
                    )
            } else {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("\(event.daysLeft)")
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(colors: [.countdownAccent, Color(red: 1, green: 0.3, blue: 0.02)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                    Text(event.daysUnitDetail)
                        .font(.title3.weight(.medium))
                        .foregroundColor(.secondary)
                }
                Text("until \(event.formattedDate)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }

            if !event.tags.isEmpty {
                Text(event.tags.map { "#\($0)" }.joined(separator: " "))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Text("The Vibe: Soul Schedule")
                .font(.caption2.weight(.semibold))
                .foregroundColor(.secondary.opacity(0.8))
        }
        .padding(28)
        .frame(width: 320)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.12), radius: 20, y: 10)
        )
    }
}

@MainActor
enum EventShareImageRenderer {
    static func renderPNG(event: Event, scale: CGFloat = 3) -> UIImage? {
        let view = EventShareCardView(event: event)
            .environment(\.colorScheme, .light)
        let renderer = ImageRenderer(content: view)
        renderer.scale = scale
        return renderer.uiImage
    }
}
