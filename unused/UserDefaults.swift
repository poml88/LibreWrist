////
////  UserDefaults.swift
////  GlucoseDirect
////
//
//import Foundation
//
//// MARK: - Keys
//
//private enum Keys: String {
//    case username = "username"
//    case keyConnection = "connection"
//    case keyLockTime = "lockTime"
//}
//
//enum Connection: Int {
//    case disconnected = 0
//    case connected = 1
//    case connecting = 2
//    case failed = -1
//    case locked = -2
//}
//
//
//
//
//extension UserDefaults {
//    var username: String {
//        get {
//            return string(forKey: Keys.username.rawValue) ?? ""
//        }
//        set {
//            if newValue.isEmpty {
//                removeObject(forKey: Keys.username.rawValue)
//            } else {
//                set(newValue, forKey: Keys.username.rawValue)
//            }
//        }
//    }
//    
//    var connected: Connection {
//        set {
//            if connected != .locked && newValue == .locked {
//                lockTime = Date()
//            }
//            set(newValue.rawValue, forKey: Keys.keyConnection.rawValue)
//            }
//        
//        get {
//            let value = Connection(rawValue: integer(forKey: Keys.keyConnection.rawValue)) ?? .disconnected
//            if value == .locked && lockTime.adding(minutes: +5) < Date() {
//                return .disconnected
//            }
//            return value
//        }
//    }
//
//    fileprivate var lockTime: Date {
//        set {
//            set(newValue, forKey: Keys.keyLockTime.rawValue)
//        }
//        get {
//            object(forKey: Keys.keyLockTime.rawValue) as? Date ?? Date.distantPast
//        }
//    }
//    
// 
// 
//
// 
//  
//
//
//
// 
// 
//
//    var sharedGlucose: Data? {
//        get {
//            return data(forKey: Keys.sharedGlucose.rawValue)
//        }
//        set {
//            if let newValue = newValue {
//                set(newValue, forKey: Keys.sharedGlucose.rawValue)
//            } else {
//                removeObject(forKey: Keys.sharedGlucose.rawValue)
//            }
//        }
//    }
//
// 
//
// 
//
//  
//
//  
//    
//    
//}
//
//extension UserDefaults {
//    static let shared = UserDefaults(suiteName: stringValue(forKey: "APP_GROUP_ID"))!
//
//    func setArray<Element>(_ array: [Element], forKey key: String) where Element: Encodable {
//        let data = try? JSONEncoder().encode(array)
//        set(data, forKey: key)
//    }
//
//    func getArray<Element>(forKey key: String) -> [Element]? where Element: Decodable {
//        guard let data = data(forKey: key) else {
//            return nil
//        }
//
//        return try? JSONDecoder().decode([Element].self, from: data)
//    }
//
//    func setObject<Element>(_ obj: Element, forKey key: String) where Element: Encodable {
//        let data = try? JSONEncoder().encode(obj)
//        set(data, forKey: key)
//    }
//
//    func getObject<Element>(forKey key: String) -> Element? where Element: Decodable {
//        guard let data = data(forKey: key) else {
//            return nil
//        }
//
//        return try? JSONDecoder().decode(Element.self, from: data)
//    }
//
//    
//}
