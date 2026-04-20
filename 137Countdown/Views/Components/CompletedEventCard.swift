//
//  CompletedEventCard.swift
//  137Countdown
//

import SwiftUI

struct CompletedEventCard: View {
    let event: CompletedEvent

    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.countdownAccent.opacity(0.35), Color.countdownAccent.opacity(0.08)],
                            center: .center,
                            startRadius: 2,
                            endRadius: 22
                        )
                    )
                    .frame(width: 44, height: 44)
                    .shadow(color: Color.countdownAccent.opacity(0.25), radius: 6, y: 2)

                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(
                        LinearGradient(colors: [.countdownAccent, Color(red: 1, green: 0.32, blue: 0.05)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .font(.title2)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .foregroundColor(.black)
                    .font(.headline)

                Text(formattedDate(event.date))
                    .font(.caption)
                    .foregroundColor(.gray)

                Text("Completed: \(formattedShortDate(event.completedDate))")
                    .font(.caption2)
                    .foregroundColor(.countdownAccent)
            }

            Spacer()

            Image(systemName: "archivebox.fill")
                .foregroundStyle(
                    LinearGradient(colors: [Color.gray.opacity(0.7), Color.gray.opacity(0.35)], startPoint: .top, endPoint: .bottom)
                )
        }
        .padding()
        .countdownRaisedCard(cornerRadius: 16, panel: true)
    }
}
