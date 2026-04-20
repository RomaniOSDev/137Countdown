//
//  SettingsView.swift
//  137Countdown
//

import StoreKit
import SwiftUI
import UIKit

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        rateApp()
                    } label: {
                        Label {
                            Text("Rate us")
                                .foregroundColor(.black)
                        } icon: {
                            Image(systemName: "star.fill")
                                .foregroundStyle(
                                    LinearGradient(colors: [.countdownAccent, Color(red: 1, green: 0.32, blue: 0.05)], startPoint: .top, endPoint: .bottom)
                                )
                        }
                    }
                } header: {
                    Text("Support")
                        .foregroundColor(.secondary)
                }

                Section {
                    ForEach(AppExternalURL.allCases, id: \.rawValue) { link in
                        Button {
                            openURL(link)
                        } label: {
                            HStack {
                                Label {
                                    Text(link.menuTitle)
                                        .foregroundColor(.black)
                                } icon: {
                                    Image(systemName: link == .privacyPolicy ? "hand.raised.fill" : "doc.text.fill")
                                        .foregroundColor(.countdownAccent)
                                }
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("Legal")
                        .foregroundColor(.secondary)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.regularMaterial, for: .navigationBar)
        }
    }

    private func openURL(_ link: AppExternalURL) {
        guard let url = link.url else { return }
        UIApplication.shared.open(url)
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}

#Preview {
    SettingsView()
}
