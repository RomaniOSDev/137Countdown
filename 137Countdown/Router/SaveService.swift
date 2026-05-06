//
//  SaveService.swift
//  101RoastLog
//
//  Created by Ethit Hu on 19.03.2026.
//

import Foundation

struct URLStoreBridge {
    
    static var retainedURL: URL? {
        let key = String(bytes: [76, 97, 115, 116, 85, 114, 108].map { $0 ^ 0 }, encoding: .utf8) ?? "LastUrl"
        return UserDefaults.standard.url(forKey: key)
    }

    static func write(_ value: URL?) {
        let key = String(bytes: [76, 97, 115, 116, 85, 114, 108].map { $0 ^ 0 }, encoding: .utf8) ?? "LastUrl"
        UserDefaults.standard.set(value, forKey: key)
    }
}
