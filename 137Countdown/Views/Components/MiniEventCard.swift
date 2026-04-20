//
//  MiniEventCard.swift
//  137Countdown
//

import SwiftUI

struct MiniEventCard: View {
    let event: Event

    private var accent: Color {
        event.colorTag == .none ? Color.countdownAccent : event.colorTag.stripeColor
    }

    var body: some View {
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(
                    LinearGradient(colors: [accent, accent.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                )
                .frame(width: 4)
                .shadow(color: accent.opacity(0.35), radius: 3, x: 1, y: 0)

            HStack {
                Image(systemName: event.category.icon)
                    .foregroundStyle(
                        LinearGradient(colors: [accent, accent.opacity(0.85)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )

                Text(event.title)
                    .foregroundColor(.black)
                    .font(.headline)
                    .lineLimit(1)

                Spacer()

                if event.isToday {
                    Text("Today!")
                        .font(.caption)
                        .foregroundColor(.countdownAccent)
                } else if event.isPast {
                    Text(event.statusText)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                } else {
                    Text("\(event.daysLeft)d")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(
                            LinearGradient(colors: [.countdownAccent, .countdownAccent.opacity(0.75)], startPoint: .top, endPoint: .bottom)
                        )
                }
            }
            .padding(.leading, 10)
        }
        .padding(.vertical, 12)
        .padding(.trailing, 14)
        .countdownRaisedCard(cornerRadius: 16, panel: true)
        .padding(.horizontal)
    }
}
