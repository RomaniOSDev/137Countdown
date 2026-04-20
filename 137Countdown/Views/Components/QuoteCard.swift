//
//  QuoteCard.swift
//  137Countdown
//

import SwiftUI

struct QuoteCard: View {
    let quote: Quote

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(quote.text)
                .font(.body)
                .foregroundColor(.black)
                .italic()

            Text("— \(quote.author)")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .countdownRaisedCard(cornerRadius: 14, panel: true)
    }
}
