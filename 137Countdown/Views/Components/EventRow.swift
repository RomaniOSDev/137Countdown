//
//  EventRow.swift
//  137Countdown
//

import SwiftUI

struct EventRow: View {
    let event: Event

    private var accent: Color {
        event.colorTag == .none ? Color.countdownAccent : event.colorTag.stripeColor
    }

    var body: some View {
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [accent, accent.opacity(0.65)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 5)
                .shadow(color: accent.opacity(0.45), radius: 4, x: 2, y: 0)

            HStack {
                Image(systemName: event.category.icon)
                    .foregroundStyle(
                        LinearGradient(colors: [accent, accent.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 30)

                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .foregroundColor(.black)
                        .font(.headline)

                    HStack(spacing: 6) {
                        Text(event.formattedDate)
                            .font(.caption)
                            .foregroundColor(.gray)
                        if event.recurrenceRule != .none {
                            Image(systemName: "repeat")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        if event.isSpotlight {
                            Image(systemName: "pin.fill")
                                .font(.caption2)
                                .foregroundColor(.countdownAccent)
                        }
                    }
                    if !event.tags.isEmpty {
                        Text(event.tags.map { "#\($0)" }.joined(separator: " "))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    if event.isPast {
                        Text("Past")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(abs(event.daysLeft))")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text(abs(event.daysLeft) == 1 ? "day ago" : "days ago")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    } else if event.isToday {
                        Text("Today!")
                            .font(.headline)
                            .foregroundColor(.countdownAccent)
                    } else {
                        Text("\(event.daysLeft)")
                            .font(.title3)
                            .bold()
                            .foregroundColor(event.daysLeft <= 7 ? .countdownAccent : .black)
                        Text(event.daysLeft == 1 ? "day" : "days")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: 76, alignment: .trailing)
            }
            .padding(.leading, 10)
        }
        .padding(.vertical, 4)
        .padding(.trailing, 8)
        .countdownRaisedCard(cornerRadius: 14, panel: false)
    }
}
