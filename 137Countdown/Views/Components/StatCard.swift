//
//  StatCard.swift
//  137Countdown
//

import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [color, color.opacity(0.75)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: color.opacity(0.35), radius: 4, y: 1)
                Text(title)
                    .foregroundColor(.gray)
                    .font(.caption)
            }

            Text(value)
                .foregroundColor(.black)
                .font(.title2)
                .bold()
                .lineLimit(2)
                .minimumScaleFactor(0.7)
        }
        .padding()
        .frame(width: 160, alignment: .leading)
        .countdownRaisedCard(cornerRadius: 14, panel: false)
    }
}
