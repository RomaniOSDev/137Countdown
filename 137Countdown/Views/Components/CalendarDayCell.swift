//
//  CalendarDayCell.swift
//  137Countdown
//

import SwiftUI

struct CalendarDayCell: View {
    let calendar: Calendar
    let date: Date
    let hasEvent: Bool
    let eventCount: Int

    var body: some View {
        VStack(spacing: 4) {
            Text("\(calendar.component(.day, from: date))")
                .font(.caption.weight(hasEvent ? .bold : .regular))
                .foregroundColor(hasEvent ? .countdownAccent : .black)

            if hasEvent {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.countdownAccent, Color.countdownAccent.opacity(0.6)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 3
                        )
                    )
                    .frame(width: 5, height: 5)
                    .shadow(color: Color.countdownAccent.opacity(0.5), radius: 3, y: 1)
            }

            if eventCount > 1 {
                Text("\(eventCount)")
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal, 2)
        .background {
            if hasEvent {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(CountdownVisual.panelFill)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.countdownAccent.opacity(0.45), Color.countdownAccent.opacity(0.12)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.countdownAccent.opacity(0.12), radius: 6, x: 0, y: 3)
            }
        }
    }
}
