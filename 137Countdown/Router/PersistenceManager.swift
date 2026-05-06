//
//  PersistenceManager.swift
//  101RoastLog
//
//  Created by Ethit Hu on 19.03.2026.
//

import Foundation

final class SessionVault {
    static let shared = SessionVault()
    
    private let savedUrlKey = VaultText.decode([34, 15, 29, 26, 59, 28, 3], key: 110)
    private let hasShownContentViewKey = VaultText.decode([18, 59, 41, 9, 50, 53, 45, 52, 25, 53, 52, 46, 63, 52, 46, 12, 51, 63, 45], key: 90)
    private let hasSuccessfulWebViewLoadKey = VaultText.decode([124, 85, 71, 103, 65, 87, 87, 81, 71, 71, 82, 65, 88, 99, 81, 86, 98, 93, 81, 67, 120, 91, 85, 80], key: 52)
    
    var cachedLink: String? {
        get {
            if let url = URLStoreBridge.retainedURL {
                return url.absoluteString
            }
            return UserDefaults.standard.string(forKey: savedUrlKey)
        }
        set {
            if let urlString = newValue {
                UserDefaults.standard.set(urlString, forKey: savedUrlKey)
                if let url = URL(string: urlString) {
                    URLStoreBridge.write(url)
                }
            } else {
                UserDefaults.standard.removeObject(forKey: savedUrlKey)
                URLStoreBridge.write(nil)
            }
        }
    }
    
    var didOpenNativeFlow: Bool {
        get {
            UserDefaults.standard.bool(forKey: hasShownContentViewKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: hasShownContentViewKey)
        }
    }
    
    var didCompleteWebLoad: Bool {
        get {
            UserDefaults.standard.bool(forKey: hasSuccessfulWebViewLoadKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: hasSuccessfulWebViewLoadKey)
        }
    }
    
    private init() {}
}

private enum VaultText {
    static func decode(_ bytes: [UInt8], key: UInt8) -> String {
        String(bytes: bytes.map { $0 ^ key }, encoding: .utf8) ?? ""
    }
}
