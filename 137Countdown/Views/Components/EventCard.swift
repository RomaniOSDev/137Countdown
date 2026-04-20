//
//  EventCard.swift
//  137Countdown
//

import SwiftUI

struct EventCard: View {
    let event: Event

    private var accent: Color {
        event.colorTag == .none ? Color.countdownAccent : event.colorTag.stripeColor
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [accent, accent.opacity(0.65)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 5)
                .shadow(color: accent.opacity(0.4), radius: 5, x: 2, y: 0)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: event.category.icon)
                        .foregroundStyle(
                            LinearGradient(colors: [accent, accent.opacity(0.85)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .font(.title2)

                    Spacer()

                    if event.isFavorite {
                        Image(systemName: "star.fill")
                            .foregroundStyle(
                                LinearGradient(colors: [.countdownAccent, .countdownAccent.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                            )
                            .shadow(color: Color.countdownAccent.opacity(0.35), radius: 3, y: 1)
                            .font(.caption)
                    }
                }

                Text(event.title)
                    .font(.headline)
                    .foregroundColor(.black)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(event.formattedDate)
                        .font(.caption)
                        .foregroundColor(.gray)
                    if event.recurrenceRule != .none {
                        Image(systemName: "repeat")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }

                VStack {
                    if event.isPast {
                        Text(event.statusText)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    } else {
                        Text("\(event.daysLeft)")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: event.daysLeft <= 3
                                        ? [.countdownAccent, Color(red: 1, green: 0.35, blue: 0.08)]
                                        : [Color(white: 0.15), Color(white: 0.38)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )

                        Text(event.daysUnitDetail)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 4)
            }
            .padding(.leading, 10)
            .padding([.vertical, .trailing])
        }
        .frame(width: 140, height: 160)
        .countdownRaisedCard(cornerRadius: 18, panel: false)
    }
}
