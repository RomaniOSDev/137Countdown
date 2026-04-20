//
//  CountdownVisualStyle.swift
//  137Countdown
//

import SwiftUI

// MARK: - Design tokens (gradients, depth)

enum CountdownVisual {
    /// Full-screen soft gradient + atmospheric glows.
    static let screenBase = LinearGradient(
        colors: [
            Color(red: 1, green: 1, blue: 1),
            Color(red: 0.97, green: 0.975, blue: 0.995),
            Color(red: 0.995, green: 0.98, blue: 0.97)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accentHalo = RadialGradient(
        colors: [
            Color.countdownAccent.opacity(0.22),
            Color.countdownAccent.opacity(0.06),
            Color.clear
        ],
        center: .topTrailing,
        startRadius: 8,
        endRadius: 420
    )

    static let coolHalo = RadialGradient(
        colors: [Color.blue.opacity(0.08), Color.clear],
        center: UnitPoint(x: 0.12, y: 0.88),
        startRadius: 16,
        endRadius: 360
    )

    /// Raised cards (white, slight cool shift).
    static let cardFill = LinearGradient(
        colors: [
            Color.white,
            Color(red: 0.995, green: 0.997, blue: 1)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardStroke = LinearGradient(
        colors: [Color.white.opacity(0.92), Color.black.opacity(0.08)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Secondary panels (quote blocks, add tile).
    static let panelFill = LinearGradient(
        colors: [
            Color(red: 1, green: 0.985, blue: 0.98),
            Color(red: 0.96, green: 0.97, blue: 0.995)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let primaryButton = LinearGradient(
        colors: [
            Color(red: 1, green: 0.32, blue: 0.05),
            Color.countdownAccent
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let primaryButtonStroke = LinearGradient(
        colors: [Color.white.opacity(0.35), Color.countdownAccent.opacity(0.5)],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Screen backdrop

struct CountdownScreenBackground: View {
    var body: some View {
        ZStack {
            CountdownVisual.screenBase
            CountdownVisual.accentHalo
            CountdownVisual.coolHalo
        }
        .ignoresSafeArea()
    }
}

// MARK: - View modifiers

struct CountdownRaisedCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 16
    var usePanelStyle: Bool = false

    func body(content: Content) -> some View {
        let fill = usePanelStyle ? CountdownVisual.panelFill : CountdownVisual.cardFill
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(fill)
                    .shadow(color: Color.black.opacity(0.10), radius: 22, x: 0, y: 12)
                    .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(CountdownVisual.cardStroke, lineWidth: 1)
            )
    }
}

extension View {
    /// Raised surface: white gradient, rim light, layered shadows.
    func countdownRaisedCard(cornerRadius: CGFloat = 16, panel: Bool = false) -> some View {
        modifier(CountdownRaisedCardModifier(cornerRadius: cornerRadius, usePanelStyle: panel))
    }

    func countdownScreenChrome() -> some View {
        background(CountdownScreenBackground())
    }
}
