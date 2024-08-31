//
//  Setings.swift
//  LibreWrist
//
//  Created by Peter Müller on 24.08.24.
//

import Foundation

private enum Keys: String {
    case username = "username"
    case keyConnection = "connection"
    case keyLockTime = "lockTime"
}

enum Connection: Int {
    case disconnected = 0
    case connected = 1
    case connecting = 2
    case failed = -1
    case locked = -2
}


extension UserDefaults {
    static let group = UserDefaults(suiteName: stringValue(forKey: "APP_GROUP_ID"))!
    
    static func stringValue(forKey key: String) -> String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String else {
            fatalError("Invalid value or undefined key")
        }
        return value
    }
    
    var username: String {
        get {
            return string(forKey: Keys.username.rawValue) ?? ""
        }
        set {
            if newValue.isEmpty {
                removeObject(forKey: Keys.username.rawValue)
            } else {
                set(newValue, forKey: Keys.username.rawValue)
            }
        }
    }
    
    var connected: Connection {
        set {
            if connected != .locked && newValue == .locked {
                lockTime = Date()
            }
            set(newValue.rawValue, forKey: Keys.keyConnection.rawValue)
            }
        
        get {
            let value = Connection(rawValue: integer(forKey: Keys.keyConnection.rawValue)) ?? .disconnected
            if value == .locked && lockTime.adding(minutes: +5) < Date() {
                return .disconnected
            }
            return value
        }
    }

    fileprivate var lockTime: Date {
        set {
            set(newValue, forKey: Keys.keyLockTime.rawValue)
        }
        get {
            object(forKey: Keys.keyLockTime.rawValue) as? Date ?? Date.distantPast
        }
    }
}



//@Observable class Settings {
class Settings {

    static let defaults: [String: Any] = [

        "displayingMillimoles": false,
//        "targetLow": 80.0,
//        "targetHigh": 170.0,
//

//        "alarmLow": 70.0,
//        "alarmHigh": 200.0,

        "libreLinkUpEmail": "",
        "libreLinkUpPassword": "",
        "libreLinkUpUserId": "",
        "libreLinkUpPatientId": "",
        "libreLinkUpCountry": "",
        "libreLinkUpRegion": "eu",
        "libreLinkUpToken": "",
        "libreLinkUpTokenExpirationDate": Date.distantPast,
        "libreLinkUpFollowing": true,
        "libreLinkUpScrapingLogbook": false,

        "lastOnlineDate": Date.distantPast,
//

    ]


//    }
//
    var displayingMillimoles: Bool = UserDefaults.group.bool(forKey: "displayingMillimoles")  {
        didSet { UserDefaults.group.set(self.displayingMillimoles, forKey: "displayingMillimoles") }
    }

//    var numberFormatter: NumberFormatter = NumberFormatter()
//
//    var targetLow: Double = UserDefaults.standard.double(forKey: "targetLow") {
//        didSet { UserDefaults.standard.set(self.targetLow, forKey: "targetLow") }
//    }
//
//    var targetHigh: Double = UserDefaults.standard.double(forKey: "targetHigh") {
//        didSet { UserDefaults.standard.set(self.targetHigh, forKey: "targetHigh") }
//    }
//

//
//    var alarmLow: Double = UserDefaults.standard.double(forKey: "alarmLow") {
//        didSet { UserDefaults.standard.set(self.alarmLow, forKey: "alarmLow") }
//    }
//
//    var alarmHigh: Double = UserDefaults.standard.double(forKey: "alarmHigh") {
//        didSet { UserDefaults.standard.set(self.alarmHigh, forKey: "alarmHigh") }
//    }
//

    var libreLinkUpEmail: String = UserDefaults.group.string(forKey: "libreLinkUpEmail") ?? ""  {
        didSet { UserDefaults.group.set(self.libreLinkUpEmail, forKey: "libreLinkUpEmail") }
    }

    var libreLinkUpPassword: String = UserDefaults.group.string(forKey: "libreLinkUpPassword") ?? "" {
        didSet { UserDefaults.group.set(self.libreLinkUpPassword, forKey: "libreLinkUpPassword") }
    }

    var libreLinkUpUserId: String = UserDefaults.group.string(forKey: "libreLinkUpUserId")!  {
        didSet { UserDefaults.group.set(self.libreLinkUpUserId, forKey: "libreLinkUpUserId") }
    }

    var libreLinkUpPatientId: String = UserDefaults.group.string(forKey: "libreLinkUpPatientId")! {
        didSet { UserDefaults.group.set(self.libreLinkUpPatientId, forKey: "libreLinkUpPatientId") }
    }

    var libreLinkUpCountry: String = UserDefaults.group.string(forKey: "libreLinkUpCountry")!  {
        didSet { UserDefaults.group.set(self.libreLinkUpCountry, forKey: "libreLinkUpCountry") }
    }

    var libreLinkUpRegion: String = UserDefaults.group.string(forKey: "libreLinkUpRegion")!  {
        didSet { UserDefaults.group.set(self.libreLinkUpRegion, forKey: "libreLinkUpRegion") }
    }

    var libreLinkUpToken: String = UserDefaults.group.string(forKey: "libreLinkUpToken")!  {
        didSet { UserDefaults.group.set(self.libreLinkUpToken, forKey: "libreLinkUpToken") }
    }

    var libreLinkUpTokenExpirationDate: Date = Date(timeIntervalSince1970: UserDefaults.group.double(forKey: "libreLinkUpTokenExpirationDate")) {
        didSet { UserDefaults.group.set(self.libreLinkUpTokenExpirationDate.timeIntervalSince1970, forKey: "libreLinkUpTokenExpirationDate") }
    }

    var libreLinkUpFollowing: Bool = UserDefaults.group.bool(forKey: "libreLinkUpFollowing")  {
        didSet { UserDefaults.group.set(self.libreLinkUpFollowing, forKey: "libreLinkUpFollowing") }
    }

    var libreLinkUpScrapingLogbook: Bool = UserDefaults.group.bool(forKey: "libreLinkUpScrapingLogbook") {
        didSet { UserDefaults.group.set(self.libreLinkUpScrapingLogbook, forKey: "libreLinkUpScrapingLogbook") }
    }
    
    var hasSeenDisclaimer: Bool = UserDefaults.group.bool(forKey: "hasSeenDisclaimer") {
        didSet { UserDefaults.group.set(self.hasSeenDisclaimer, forKey: "hasSeenDisclaimer") }
    }


    var lastOnlineDate: Date = Date(timeIntervalSince1970: UserDefaults.group.double(forKey: "lastOnlineDate")) {
        didSet { UserDefaults.group.set(self.lastOnlineDate.timeIntervalSince1970, forKey: "lastOnlineDate") }
    }


//class HexDataFormatter: Formatter {
//    override func string(for obj: Any?) -> String? {
//        return (obj as! Data).hex
//    }
//    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
//        var str = string.filter(\.isHexDigit)
//        if str.count % 2 == 1 { str = "0" + str}
//        obj?.pointee = str.bytes as AnyObject
//        return true
//    }
}

var settings = Settings()
