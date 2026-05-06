//
//  PrivacyWebView.swift
//  101RoastLog
//
//  Created by Ethit Hu on 19.03.2026.
//

import SwiftUI
import WebKit

struct PrivacyGatewayView: View {
    let urlString: String
    var onFailure: () -> Void
    var onSuccess: (() -> Void)? = nil
    
    @State private var webView: WKWebView = WKWebView()
    @State private var canGoBack: Bool = false
    @State private var isLoading: Bool = true
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Navigation Bar
                HStack {
                    Button(action: {
                        webView.goBack()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(canGoBack ? .white : .gray)
                            .padding(.vertical, 12)
                            .padding(.horizontal)
                    }
                    .disabled(!canGoBack)
                    
                    Spacer()
                    
                    Button(action: {
                        webView.reload()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal)
                    }
                }
                .frame(height: 60)
                .background(Color.black)
                
                // WebView
                GatewayWebRepresentable(
                    webView: webView,
                    urlString: urlString,
                    canGoBack: $canGoBack,
                    isLoading: $isLoading,
                    onFailure: onFailure,
                    onSuccess: onSuccess
                )
            }
            .ignoresSafeArea()
            .statusBar(hidden: true)
            
            // Loading Indicator
            if isLoading {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(2.0)
                }
            }
        }
        
    }
}

// MARK: - UIViewRepresentable
struct GatewayWebRepresentable: UIViewRepresentable {
    let webView: WKWebView
    let urlString: String
    @Binding var canGoBack: Bool
    @Binding var isLoading: Bool
    var onFailure: () -> Void
    var onSuccess: (() -> Void)?
    
    func makeUIView(context: Context) -> WKWebView {
        // Configuration
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        
        // Fix for "Gray Bottom" / Safe Area issues
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.backgroundColor = .black
        webView.isOpaque = false

        webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        webView.allowsBackForwardNavigationGestures = true
        
        // Load initial URL
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Updates handled by coordinator state
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: GatewayWebRepresentable
        private var failureCalled = false
        
        init(parent: GatewayWebRepresentable) {
            self.parent = parent
        }
        
        // MARK: - WKUIDelegate (Handle Popups / window.open)
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            // Intercept target="_blank" or window.open
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }
        
        // Handle HTTP Response Codes
        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            if let httpResponse = navigationResponse.response as? HTTPURLResponse {
                // Only check for failure if we haven't locked in yet (Initial Check)
                if SessionVault.shared.cachedLink == nil && !failureCalled {
                    if (400...599).contains(httpResponse.statusCode) {
                        failureCalled = true
                        SessionVault.shared.didOpenNativeFlow = true
                        decisionHandler(.cancel)
                        
                        DispatchQueue.main.async {
                            self.parent.onFailure()
                        }
                        return
                    }
                }
            }
            decisionHandler(.allow)
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url {
                 if [SchemeMask.reveal([45, 33, 41, 44, 52, 47], key: 64), SchemeMask.reveal([23, 6, 15], key: 99), SchemeMask.reveal([56, 38, 56], key: 75)].contains(url.scheme) {
                     if UIApplication.shared.canOpenURL(url) {
                         UIApplication.shared.open(url)
                     }
                     decisionHandler(.cancel)
                     return
                 }
            }
            decisionHandler(.allow)
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.canGoBack = webView.canGoBack
            parent.isLoading = false

            if SessionVault.shared.cachedLink == nil {
                if let currentUrl = webView.url?.absoluteString {
                    SessionVault.shared.cachedLink = currentUrl
                    SessionVault.shared.didCompleteWebLoad = true
                    DispatchQueue.main.async {
                        self.parent.onSuccess?()
                    }
                }
            } else {
                SessionVault.shared.didCompleteWebLoad = true
                DispatchQueue.main.async {
                    self.parent.onSuccess?()
                }
            }
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            
            if SessionVault.shared.cachedLink == nil && !failureCalled {
                failureCalled = true
                
                SessionVault.shared.didOpenNativeFlow = true
                DispatchQueue.main.async {
                    self.parent.onFailure()
                }
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
        }
    }
}

private enum SchemeMask {
    static func reveal(_ bytes: [UInt8], key: UInt8) -> String {
        String(bytes: bytes.map { $0 ^ key }, encoding: .utf8) ?? ""
    }
}
