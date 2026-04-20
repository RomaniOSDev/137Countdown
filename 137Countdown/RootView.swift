//
//  RootView.swift
//  137Countdown
//

import SwiftUI

/// Shows onboarding once, then the main app.
struct RootView: View {
    @AppStorage("countdown_hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                ContentView()
                    .transition(.opacity)
            } else {
                OnboardingView {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        hasCompletedOnboarding = true
                    }
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: hasCompletedOnboarding)
    }
}

#Preview("Onboarding") {
    OnboardingView(onFinish: {})
}

#Preview("App") {
    RootView()
}
