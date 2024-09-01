//
//  SecureDefaults.swift
//  LibreWrist
//
//  Created by Peter Müller on 18.08.24.
//

import Foundation
import SecureDefaults

private enum Keys: String {
    case password = "llu.password"
}

extension SecureDefaults {
    static let sgroup = SecureDefaults(suiteName: stringSValue(forKey: "APP_GROUP_ID"))!
    
    static func stringSValue(forKey key: String) -> String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String else {
            fatalError("Invalid value or undefined key")
        }
        return value
    }
}

