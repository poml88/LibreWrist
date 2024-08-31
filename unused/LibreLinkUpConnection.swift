////
////  LibreLinkUpConnection.swift
////  GlucoseDirectApp
////
//
//import Foundation
//import OSLog
//import SwiftUI
//import SecureDefaults
//
//
//struct GlucoseItem: Decodable {
//    let timestamp: String?
//    let valueInMgPerDL: Int?
//    let trendArrow: Int?
//    let measurementColor: Int?
//    let value: Int?
//
//    enum CodingKeys: String, CodingKey {
//        case timestamp = "Timestamp"
//        case valueInMgPerDL = "ValueInMgPerDl"
//        case trendArrow = "TrendArrow"
//        case measurementColor = "MeasurementColor"
//        case value = "Value"
//    }
//    
//    
//
////    func isOutdated() -> Bool {
////        if let timestamp = Date.enUS(from: timestamp ?? "") {
////            //debugPrint(Date().adding(minutes: -3))
////            //NSLog(Date().adding(minutes: -3))
////            return timestamp < Date().adding(minutes: -3)
////        }
////        return true
////    }
//
//    static let preview: GlucoseItem = GlucoseItem(
//            timestamp: "8/20/2069 3:15:16 PM",
//            valueInMgPerDL: 105,
//            trendArrow: 3,
//            measurementColor: 1,
//            value: 105
//    )
//
//    static let unspecific: GlucoseItem = GlucoseItem(
//            timestamp: "8/20/2069 3:15:16 PM",
//            valueInMgPerDL: -1,
//            trendArrow: -1,
//            measurementColor: -1,
//            value: -1
//    )
//}
//
//struct FetchStatus {
//    static let FAILED = 2
//    static let LOCKED = 429
//}
//
//class LibreLinkUpConnection {
//    var sensor: Sensor?
//    
//    func connectConnection() {
//        Logger.services.info("LibreLinkUp connectConnection")
//        Task {
//            do {
//                LibreLinkUpConnection.lastLogin = nil
//                
//                try await self.processLogin()
//                
//                //                self.managerQueue.async {
//                //                    self.find()
//                //                }
//            } catch {
//                Logger.services.error("\(error)")
//            }
//        }
//    }
//    
//    func getGlucoseData() {
//        Logger.services.info("LibreLinkUp getGlucoseData")
//
//       Task {
//            do {
//                try await self.processFetch()
//            } catch {
//                Logger.services.error("Error: \(error)")
//            }
//        }
//    }
//    
//
//#warning("Safe lastlogin to UserDefaults")
//    private static var lastLogin: LibreLinkLogin?
//    //    private let oneMinuteReadingUUID = CBUUID(string: "0898177A-EF89-11E9-81B4-2A2AE2DBCCE4")
//    //    private var oneMinuteReadingCharacteristic: CBCharacteristic?
//    
//    private let requestHeaders = [
//        "User-Agent": "Mozilla/5.0",
//        "Content-Type": "application/json",
//        "product": "llu.ios",
//        "version": "4.7.0",
//        "Accept-Encoding": "gzip, deflate, br",
//        "Connection": "keep-alive",
//        "Pragma": "no-cache",
//        "Cache-Control": "no-cache",
//    ]
//    
//    private lazy var dateFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.locale = Locale(identifier: "en_US_POSIX")
//        formatter.dateFormat = "M/d/yyyy h:mm:ss a"
//        return formatter
//    }()
//
//    private lazy var jsonDecoder: JSONDecoder? = {
//        let decoder = JSONDecoder()
//        decoder.dateDecodingStrategy = .formatted(dateFormatter)
//
//        return decoder
//    }()
//
//    
//    private func processFetch() async throws {
//        Logger.services.info("LibreLinkUp processFetch")
//
//        try await processLogin()
//
//        let fetchResponse = try await fetch()
//
//        if let sensorAge = fetchResponse.data?.activeSensors?.first?.sensor?.age ?? fetchResponse.data?.connection?.sensor?.age,
//           let sensorSerial = fetchResponse.data?.activeSensors?.first?.sensor?.serial ?? fetchResponse.data?.connection?.sensor?.serial,
//           let sensor = sensor
//        {
//            if sensor.serial != sensorSerial {
//                let sensor = Sensor(family: sensor.family, type: sensor.type, region: sensor.region, serial: sensorSerial, state: sensor.state, age: sensorAge, lifetime: sensor.lifetime)
//               // sendUpdate(sensor: sensor)
//
//                self.sensor = sensor
//            }
//
//            if sensorAge >= sensor.lifetime {
//              //  sendUpdate(age: sensorAge, state: .expired)
//
//            } else if sensorAge > sensor.warmupTime {
//            //    sendUpdate(age: sensorAge, state: .ready)
//
//            } else if sensorAge <= sensor.warmupTime {
//            //    sendUpdate(age: sensorAge, state: .starting)
//            }
//        }
//
//        let data = (fetchResponse.data?.graphData ?? []) + [fetchResponse.data?.connection?.glucoseMeasurement]
//
//        sendUpdate(readings: data.compactMap {
//            $0
//        }.map {
//            SensorReading.createGlucoseReading(timestamp: $0.timestamp, glucoseValue: $0.value)
//        })
//    }
//    
//    func sendUpdate(readings: [SensorReading] = []) {
//        Logger.services.info("SensorReadings: \(readings)")
//        
//        //subject?.send(.addSensorReadings(readings: readings))
//        print(".addSensorReadings(readings: readings)")
//    }
//    
//    private func tou(apiRegion: String? = nil, authToken: String) async throws -> LibreLinkResponse<LibreLinkResponseLogin> {
//        Logger.services.info("LibreLinkUp tou")
//
//        var urlString: String?
//        if let apiRegion = apiRegion {
//            urlString = "https://api-\(apiRegion).libreview.io/auth/continue/tou"
//        } else {
//            urlString = "https://api.libreview.io/auth/continue/tou"
//        }
//
//        guard let urlString = urlString else {
//            throw LibreLinkError.invalidURL
//        }
//
//        guard let url = URL(string: urlString) else {
//            throw LibreLinkError.invalidURL
//        }
//
//        Logger.services.info("LibreLinkUp tou, url: \(url.absoluteString)")
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//
//        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
//
//        for (header, value) in requestHeaders {
//            request.setValue(value, forHTTPHeaderField: header)
//        }
//
//        let (data, response) = try await URLSession.shared.data(for: request)
//        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
//
//        let string = String(data: data, encoding: String.Encoding.utf8) ?? ""
//        Logger.services.info("LibreLinkUp tou, response: \(string)")
//
//        if statusCode == 200 {
//            return try decode(LibreLinkResponse<LibreLinkResponseLogin>.self, data: data)
//        } else if statusCode == 911 {
//            throw LibreLinkError.maintenance
//        }
//
//        throw LibreLinkError.unknownError
//    }
//    
//    private func processLogin(apiRegion: String? = nil) async throws {
//        print("lastLogin if");print(LibreLinkUpConnection.lastLogin); print(Date())
//        if LibreLinkUpConnection.lastLogin == nil || LibreLinkUpConnection.lastLogin!.authExpires <= Date() {
//            Logger.services.info("LibreLinkUp processLogin")
//            
//            var loginResponse = try await login(apiRegion: apiRegion)
//                        if loginResponse.status == 4 {
//                            Logger.services.info("LibreLinkUp processLogin, request to accept tou")
//            
//                            guard let authToken = loginResponse.data?.authTicket?.token,
//                                  !authToken.isEmpty
//                            else {
//                                UserDefaults.standard.connected = .disconnected
//            
//                                throw LibreLinkError.missingUserOrToken
//                            }
//            
//                            loginResponse = try await tou(apiRegion: apiRegion, authToken: authToken)
//                        }
//            
//                        if let redirect = loginResponse.data?.redirect, let region = loginResponse.data?.region, redirect, !region.isEmpty {
//                            Logger.services.info("LibreLinkUp processLogin, redirect to userCountry: \(region)")
//            
//                            try await processLogin(apiRegion: region)
//                            return
//                        }
//            
//                        guard let userID = loginResponse.data?.user?.id,
//                              let apiRegion = apiRegion ?? loginResponse.data?.user?.apiRegion,
//                              let authToken = loginResponse.data?.authTicket?.token,
//                              let authExpires = loginResponse.data?.authTicket?.expires,
//                              !apiRegion.isEmpty, !authToken.isEmpty
//                        else {
//                            UserDefaults.standard.connected = .disconnected
//            
//                            throw LibreLinkError.missingUserOrToken
//                        }
//            
//                        Logger.services.info("LibreLinkUp processLogin, apiRegion: \(apiRegion)")
//                        Logger.services.info("LibreLinkUp processLogin, authExpires: \(authExpires)")
//            
//                        let connectResponse = try await connect(apiRegion: apiRegion, authToken: authToken)
//            
//                        guard let patientID = connectResponse.data?.first(where: { $0.patientID == userID })?.patientID ?? connectResponse.data?.first?.patientID else {
//                            UserDefaults.standard.connected = .disconnected
//            
//                            throw LibreLinkError.missingPatientID
//                        }
//            
//                        Logger.services.info("LibreLinkUp processLogin, patientID: \(patientID)")
//            
//            LibreLinkUpConnection.lastLogin = LibreLinkLogin(patientID: patientID, apiRegion: apiRegion, authToken: authToken, authExpires: authExpires)
//            print(LibreLinkUpConnection.lastLogin)
//            print("lastLogin")
//            UserDefaults.standard.connected = .connected
//        }
//    }
//    
//    
//    private func login(apiRegion: String? = nil) async throws -> LibreLinkResponse<LibreLinkResponseLogin> {
//        Logger.services.info("LibreLinkUp login")
//        
//        guard !UserDefaults.standard.username.isEmpty, !((SecureDefaults().string(forKey: "libre-direct.settings.password")?.isEmpty) == nil) else {
//            UserDefaults.standard.connected = .disconnected
//            
//            throw LibreLinkError.missingCredentials
//        }
//        
//        var urlString: String?
//        if let apiRegion = apiRegion {
//            urlString = "https://api-\(apiRegion).libreview.io/llu/auth/login"
//        } else {
//            urlString = "https://api.libreview.io/llu/auth/login"
//        }
//        
//        guard let urlString = urlString else {
//            throw LibreLinkError.invalidURL
//        }
//        
//        guard let url = URL(string: urlString) else {
//            throw LibreLinkError.invalidURL
//        }
//        
//        Logger.services.info("LibreLinkUp login, url: \(url.absoluteString)")
//        
//        guard let credentials = try? JSONSerialization.data(withJSONObject: [
//            "email": UserDefaults.standard.username,
//            "password": SecureDefaults().string(forKey: "libre-direct.settings.password")
//        ]) else {
//            throw LibreLinkError.serializationError
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.httpBody = credentials
//        
//        for (header, value) in requestHeaders {
//            request.setValue(value, forHTTPHeaderField: header)
//        }
//        
//        let (data, response) = try await URLSession.shared.data(for: request)
//        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
//        let dataResponse :String = String(data: data, encoding: String.Encoding.utf8) ?? ""
//        
//        Logger.services.info("LibreLinkUp login, response: \(dataResponse)")
//        
//        if statusCode == 200 {
//            return try decode(LibreLinkResponse<LibreLinkResponseLogin>.self, data: data)
//        } else if statusCode == 911 {
//            throw LibreLinkError.maintenance
//        } else if statusCode == 401 {
//            throw LibreLinkError.invalidCredentials
//        }
//        
//        throw LibreLinkError.unknownError
//    }
//    
//    private func connect(apiRegion: String, authToken: String) async throws -> LibreLinkResponse<[LibreLinkResponseConnect]> {
//        Logger.services.info("LibreLinkUp connect")
//
//        guard let url = URL(string: "https://api-\(apiRegion).libreview.io/llu/connections") else {
//            throw LibreLinkError.invalidURL
//        }
//
//        Logger.services.info("LibreLinkUp connect, url: \(url.absoluteString)")
//
//        var request = URLRequest(url: url)
//        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
//
//        for (header, value) in requestHeaders {
//            request.setValue(value, forHTTPHeaderField: header)
//        }
//
//        let (data, response) = try await URLSession.shared.data(for: request)
//        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
//
//        let string = String(data: data, encoding: String.Encoding.utf8) ?? ""
//        Logger.services.info("LibreLinkUp connect, response: \(string)")
//
//        if statusCode == 200 {
//            return try decode(LibreLinkResponse<[LibreLinkResponseConnect]>.self, data: data)
//        } else if statusCode == 911 {
//            throw LibreLinkError.maintenance
//        } else if statusCode == 401 {
//            throw LibreLinkError.invalidCredentials
//        }
//
//        throw LibreLinkError.unknownError
//    }
//    
//    private func fetch() async throws -> LibreLinkResponse<LibreLinkResponseFetch> {
//        Logger.services.info("LibreLinkUp fetch")
//
//        guard let lastLogin = LibreLinkUpConnection.lastLogin else {
//            throw LibreLinkError.missingLoginSession
//        }
//
//        guard let url = URL(string: "https://api-\(lastLogin.apiRegion).libreview.io/llu/connections/\(lastLogin.patientID)/graph") else {
//            throw LibreLinkError.invalidURL
//        }
//
//        Logger.services.info("LibreLinkUp fetch, url: \(url.absoluteString)")
//
//        var request = URLRequest(url: url)
//        request.setValue("Bearer \(lastLogin.authToken)", forHTTPHeaderField: "Authorization")
//
//        for (header, value) in requestHeaders {
//            request.setValue(value, forHTTPHeaderField: header)
//        }
//
//        let (data, response) = try await URLSession.shared.data(for: request)
//        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
//
//        let string = String(data: data, encoding: String.Encoding.utf8) ?? ""
//        Logger.services.info("LibreLinkUp fetch, response: \(string)")
//
//        if statusCode == 200 {
//            return try decode(LibreLinkResponse<LibreLinkResponseFetch>.self, data: data)
//        } else if statusCode == 911 {
//            throw LibreLinkError.maintenance
//        } else if statusCode == 401 {
//            throw LibreLinkError.invalidCredentials
//        }
//
//        throw LibreLinkError.unknownError
//    }
//    
//    private func decode<T: Decodable>(_ type: T.Type, data: Data) throws -> T {
//        guard let jsonDecoder = jsonDecoder else {
//            throw LibreLinkError.decoderError
//        }
//
//        return try jsonDecoder.decode(T.self, from: data)
//    }
//}
//
//
//// MARK: - LibreLinkResponse
//
//private struct LibreLinkResponse<T: Codable>: Codable {
//    let status: Int
//    let data: T?
//}
//
//// MARK: - LibreLinkResponseLogin
//
//private struct LibreLinkResponseLogin: Codable {
//    let user: LibreLinkResponseUser?
//    let authTicket: LibreLinkResponseAuthentication?
//    let redirect: Bool?
//    let region: String?
//}
//
//// MARK: - LibreLinkResponseConnect
//
//private struct LibreLinkResponseConnect: Codable {
//    enum CodingKeys: String, CodingKey { case patientID = "patientId" }
//
//    let patientID: String?
//}
//
//// MARK: - LibreLinkResponseFetch
//
//private struct LibreLinkResponseFetch: Codable {
//    let connection: LibreLinkResponseConnection?
//    let activeSensors: [LibreLinkResponseActiveSensors]?
//    let graphData: [LibreLinkResponseGlucose]?
//}
//
//// MARK: - LibreLinkResponseConnection
//
//private struct LibreLinkResponseConnection: Codable {
//    let sensor: LibreLinkResponseSensor?
//    let glucoseMeasurement: LibreLinkResponseGlucose?
//}
//
//// MARK: - LibreLinkResponseActiveSensors
//
//private struct LibreLinkResponseActiveSensors: Codable {
//    let sensor: LibreLinkResponseSensor?
//    let device: LibreLinkResponseDevice?
//}
//
//// MARK: - LibreLinkResponseDevice
//
//private struct LibreLinkResponseDevice: Codable {
//    enum CodingKeys: String, CodingKey { case dtid
//        case version = "v"
//    }
//
//    let dtid: Int
//    let version: String
//}
//
//// MARK: - LibreLinkResponseSensor
//
//private struct LibreLinkResponseSensor: Codable {
//    enum CodingKeys: String, CodingKey { case sn
//        case activation = "a"
//    }
//
//    let sn: String
//    let activation: Double
//
//    var age: Int {
//        let activationDate = Date(timeIntervalSince1970: activation)
//        return Calendar.current.dateComponents([.minute], from: activationDate, to: Date()).minute ?? 0
//    }
//}
//
//private extension LibreLinkResponseSensor {
//    var serial: String {
//        return String(sn.dropLast())
//    }
//}
//
//// MARK: - LibreLinkResponseGlucose
//
//private struct LibreLinkResponseGlucose: Codable {
//    enum CodingKeys: String, CodingKey { case timestamp = "Timestamp"
//        case value = "ValueInMgPerDl"
//    }
//
//    let timestamp: Date
//    let value: Double
//}
//
//// MARK: - LibreLinkResponseUser
//
//private struct LibreLinkResponseUser: Codable {
//    let id: String?
//    let country: String
//}
//
//private extension LibreLinkResponseUser {
//    var apiRegion: String {
//        if ["ae", "ap", "au", "de", "eu", "fr", "jp", "la", "us"].contains(country.lowercased()) {
//            return country.lowercased()
//        }
//
//        if country.lowercased() == "gb" {
//            return "eu2"
//        }
//
//        return "eu"
//    }
//}
//
//// MARK: - LibreLinkResponseAuthentication
//
//private struct LibreLinkResponseAuthentication: Codable {
//    let token: String
//    let expires: Double
//}
//
//
//
//
//private struct LibreLinkLogin: Codable {
//    // MARK: Lifecycle
//    
//    init(patientID: String, apiRegion: String, authToken: String, authExpires: Double) {
//        self.patientID = patientID
//        self.apiRegion = apiRegion.lowercased()
//        self.authToken = authToken
//        self.authExpires = Date(timeIntervalSince1970: authExpires)
//    }
//    
//    // MARK: Internal
//    
//    let patientID: String
//    let apiRegion: String
//    let authToken: String
//    let authExpires: Date
//}
//
//struct SensorConnectionConfigurationOption {
//    let id: String
//    let name: String
//    let value: Binding<String>
//    let isSecret: Bool
//}
//
//private enum LibreLinkError: Error {
//    case unknownError
//    case maintenance
//    case invalidURL
//    case serializationError
//    case missingLoginSession
//    case missingUserOrToken
//    case missingPatientID
//    case invalidCredentials
//    case missingCredentials
//    case notAuthenticated
//    case decoderError
//    case missingData
//    case parsingError
//    case cannotLock
//    case missingStatusCode
//}
//
//// MARK: CustomStringConvertible
//
//extension LibreLinkError: CustomStringConvertible {
//    var description: String {
//        switch self {
//        case .unknownError:
//            return "Unknown error"
//        case .missingStatusCode:
//            return "Missing status code"
//        case .maintenance:
//            return "Maintenance"
//        case .invalidURL:
//            return "Invalid url"
//        case .serializationError:
//            return "Serialization error"
//        case .missingUserOrToken:
//            return "Missing user or token"
//        case .missingLoginSession:
//            return "Missing login session"
//        case .missingPatientID:
//            return "Missing patient id"
//        case .invalidCredentials:
//            return "Invalid credentials (check 'Settings' > 'Connection Settings')"
//        case .missingCredentials:
//            return "Missing credentials (check 'Settings' > 'Connection Settings')"
//        case .notAuthenticated:
//            return "Not authenticated"
//        case .decoderError:
//            return "Decoder error"
//        case .missingData:
//            return "Missing data"
//        case .parsingError:
//            return "Parsing error"
//        case .cannotLock:
//            return "Cannot lock"
//        }
//    }
//}
