////
////  MainDelegate.swift
////  LibreWrist
////
////  Created by Peter Müller on 24.08.24.
////
//
//import SwiftUI
////import CoreBluetooth
////import AVFoundation
////import os.log
//
//
////protocol Logging {
////    var main: MainDelegate! { get set }
////}
////
////extension Logging {
////    func log(_ msg: String)      { main?.log(msg) }
////    func debugLog(_ msg: String) { main?.debugLog(msg) }
////
////    var app: AppState            { main.app }
////    var settings: Settings       { main.settings }
////}
//
//
//public class MainDelegate: UIResponder, UIApplicationDelegate, UIWindowSceneDelegate, UNUserNotificationCenterDelegate {
//
////    var app: AppState
////    var logger: Logger
////    var log: Log
////    var history: History
//    var settings: Settings
//
////    var centralManager: CBCentralManager
////    var bluetoothDelegate: BluetoothDelegate
////    var nfc: NFC
////    var healthKit: HealthKit?
//    var libreLinkUp: LibreLinkUp?
////    var nightscout: Nightscout?
////    var eventKit: EventKit?
//
//
//    override init() {
//
//        UserDefaults.standard.register(defaults: Settings.defaults)
//
//        settings = Settings()
////        logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Debug")
////        log = Log()
////        history = History()
////        app = AppState()
//
////        bluetoothDelegate = BluetoothDelegate()
////        centralManager = CBCentralManager(delegate: bluetoothDelegate,
////                                          queue: nil,
////                                          options: [CBCentralManagerOptionRestoreIdentifierKey: "DiaBLE"])
////
////        nfc = NFC()
////        healthKit = HealthKit()
//
////        super.init()
////
////        let welcomeMessage = "Welcome to DiaBLE!\n\nTip: switch from [Basic] to [Test] mode to sniff incoming BLE data running side-by-side with Trident and other apps.\n\nHint: better [Stop] me to avoid excessive logging during normal use.\n\nWarning: edit out your sensitive personal data after [Copy]ing and before pasting into your reports."
////
////        log.entries = [LogEntry(message: "\(welcomeMessage)"), LogEntry(message: "\(settings.logging ? "Log started" : "Log stopped") \(Date().local)")]
////        debugLog("User defaults: \(Settings.defaults.keys.map { [$0, UserDefaults.standard.dictionaryRepresentation()[$0]!] }.sorted{($0[0] as! String) < ($1[0] as! String) })")
////
////        app.main = self
////        bluetoothDelegate.main = self
////        nfc.main = self
////
////        UNUserNotificationCenter.current().delegate = self
////        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
////
////        let numberFormatter = NumberFormatter()
////        numberFormatter.minimumFractionDigits = 8
////        settings.numberFormatter = numberFormatter
//
//        Task {
//
////            if let healthKit {
////                healthKit.main = self
////                healthKit.authorize { [self] in
////                    log("HealthKit: \($0 ? "" : "not ")authorized")
////                    if healthKit.isAuthorized {
////                        healthKit.read { [self] in debugLog("HealthKit: last 12 stored values: \($0[..<(min(12, $0.count))])") }
////                    }
////                }
////            } else {
////                log("HealthKit: not available")
////            }
//
//            libreLinkUp = LibreLinkUp(main: self)
////            nightscout = Nightscout(main: self)
////            if let (values, _) = try? await nightscout?.read() {
////                history.nightscoutValues = values
////            }
////            eventKit = EventKit(main: self)
////            eventKit?.sync()
////
////            // features currently in beta testing
////            if settings.userLevel >= .test {
////                Libre3.testAESCCM()
////            }
//
//        }
//
//    }
//
//
////    public func log(_ msg: String, level: LogLevel = .info, label: String = "") {
////        if settings.logging || msg.hasPrefix("Log") {
////            let entry = LogEntry(message: msg, level: level, label: label)
////            Task { @MainActor in
////                if settings.reversedLog {
////                    log.entries.insert(entry, at: 0)
////                } else {
////                    log.entries.append(entry)
////                }
////                print(msg)
////                if settings.userLevel > .basic {
////                    logger.log("\(msg, privacy: .public)")
////                }
////                if !entry.label.isEmpty {
////                    log.labels.insert(entry.label)
////                }
////            }
////        }
////    }
////
////
////    public func debugLog(_ msg: String) {
////        if settings.userLevel > .basic {
////            log(msg, level: .debug)
////        }
////    }
////
////    public func status(_ text: String) {
////        Task { @MainActor in
////            app.status = text
////        }
////    }
////
////    public func errorStatus(_ text: String) {
////        if !app.status.contains(text) {
////            Task { @MainActor in
////                app.status.append("\n\(text)")
////            }
////        }
////    }
////
////
////    // FIXME: causes double instantiation of MainDelegate
////
////    //    public func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
////    //        let sceneConfiguration = UISceneConfiguration(name: "LaunchConfiguration", sessionRole: connectingSceneSession.role)
////    //        sceneConfiguration.delegateClass = MainDelegate.self
////    //        return sceneConfiguration
////    //    }
////
////
////    public func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
////        if let shortcutItem = connectionOptions.shortcutItem {
////            if shortcutItem.type == "NFC" {
////                if nfc.isAvailable {
////                    nfc.startSession()
////                }
////            }
////        }
////    }
////
////    public func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
////        if shortcutItem.type == "NFC" {
////            if nfc.isAvailable {
////                nfc.startSession()
////            }
////        }
////        completionHandler(true)
////    }
////
////
////    public func rescan() {
////        if let device = app.device {
////            centralManager.cancelPeripheralConnection(device.peripheral!)
////        }
////        if centralManager.state == .poweredOn {
////            settings.stoppedBluetooth = false
////            if !(settings.preferredDevicePattern.matches("abbott") || settings.preferredDevicePattern.matches("dexcom")) {
////                log("Bluetooth: scanning...")
////                status("Scanning...")
////                centralManager.scanForPeripherals(withServices: nil, options: nil)
////            } else {
////                if !settings.preferredDevicePattern.matches("dexcom"),
////                   let peripheral = centralManager.retrieveConnectedPeripherals(withServices: [CBUUID(string: Libre3.UUID.data.rawValue)]).first {
////                    log("Bluetooth: retrieved \(peripheral.name ?? "unnamed peripheral")")
////                    bluetoothDelegate.centralManager(centralManager, didDiscover: peripheral, advertisementData: [CBAdvertisementDataServiceUUIDsKey: [CBUUID(string: Libre3.UUID.data.rawValue)]], rssi: 0)
////                } else if !settings.preferredDevicePattern.matches("dexcom"),
////                          let peripheral = centralManager.retrieveConnectedPeripherals(withServices: [CBUUID(string: Abbott.dataServiceUUID)]).first {
////                    log("Bluetooth: retrieved \(peripheral.name ?? "unnamed peripheral")")
////                    bluetoothDelegate.centralManager(centralManager, didDiscover: peripheral, advertisementData: [CBAdvertisementDataServiceUUIDsKey: [CBUUID(string: Abbott.dataServiceUUID)]], rssi: 0)
////                } else if !settings.preferredDevicePattern.matches("abbott"),
////                          let peripheral = centralManager.retrieveConnectedPeripherals(withServices: [CBUUID(string: Dexcom.UUID.advertisement.rawValue)]).first {
////                    log("Bluetooth: retrieved \(peripheral.name ?? "unnamed peripheral")")
////                    bluetoothDelegate.centralManager(centralManager, didDiscover: peripheral, advertisementData: [CBAdvertisementDataServiceUUIDsKey: [CBUUID(string: Dexcom.UUID.advertisement.rawValue)]], rssi: 0)
////                } else {
////                    log("Bluetooth: scanning for a Libre/Dexcom...")
////                    status("Scanning for a Libre/Dexcom...")
////                    centralManager.scanForPeripherals(withServices: nil, options: nil)
////                }
////            }
////        } else {
////            log("Bluetooth is powered off: cannot scan")
////        }
////        Task {
////            healthKit?.read()
////            if let (values, _) = try? await nightscout?.read() {
////                history.nightscoutValues = values
////            }
////        }
////    }
////
////
////    public func playAlarm() {
////        let currentGlucose = app.currentGlucose
////        if !settings.mutedAudio {
////            do {
////                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, options: [.duckOthers])
////                try AVAudioSession.sharedInstance().setActive(true)
////            } catch {
////                log("Audio Session error: \(error)")
////            }
////            let soundName = currentGlucose > Int(settings.alarmHigh) ? "alarm_high" : "alarm_low"
////            let audioPlayer = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: soundName, ofType: "mp3")!), fileTypeHint: "mp3")
////            audioPlayer.play()
////            _ = Timer.scheduledTimer(withTimeInterval: 4, repeats: false) {
////                _ in audioPlayer.stop()
////                do {
////                    try AVAudioSession.sharedInstance().setActive(false)
////                } catch { }
////            }
////        }
////        if !settings.disabledNotifications {
////            let times = currentGlucose > Int(settings.alarmHigh) ? 3 : 4
////            let pause = times == 3 ? 1.0 : 5.0 / 6
////            for s in 0 ..< times {
////                DispatchQueue.main.asyncAfter(deadline: .now() + Double(s) * pause) {
////                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
////                }
////            }
////        }
////    }
////
////
////    func parseSensorData(_ sensor: Sensor) {
////
////        sensor.detailFRAM()
////
////        if sensor.history.count > 0 || sensor.trend.count > 0 {
////
////            let calibrationInfo = sensor.calibrationInfo
////            if sensor.serial == settings.activeSensorSerial {
////                settings.activeSensorCalibrationInfo = calibrationInfo
////            }
////
////            history.rawTrend = sensor.trend
////            log("Raw trend: \(sensor.trend.map(\.rawValue))")
////            debugLog("Raw trend temperatures: \(sensor.trend.map(\.rawTemperature))")
////            let factoryTrend = sensor.factoryTrend
////            history.factoryTrend = factoryTrend
////            log("Factory trend: \(factoryTrend.map(\.value))")
////            log("Trend temperatures: \(factoryTrend.map { Double(String(format: "%.1f", $0.temperature))! }))")
////            history.rawValues = sensor.history
////            log("Raw history: \(sensor.history.map(\.rawValue))")
////            debugLog("Raw historic temperatures: \(sensor.history.map(\.rawTemperature))")
////            let factoryHistory = sensor.factoryHistory
////            history.factoryValues = factoryHistory
////            log("Factory history: \(factoryHistory.map(\.value))")
////            log("Historic temperatures: \(factoryHistory.map { Double(String(format: "%.1f", $0.temperature))! })")
////
////            // TODO
////            debugLog("Trend has errors: \(sensor.trend.map(\.hasError))")
////            debugLog("Trend data quality: [\n\(sensor.trend.map(\.dataQuality.description).joined(separator: ",\n"))\n]")
////            debugLog("Trend quality flags: [\(sensor.trend.map { "0" + String($0.dataQualityFlags,radix: 2).suffix(2) }.joined(separator: ", "))]")
////            debugLog("History has errors: \(sensor.history.map(\.hasError))")
////            debugLog("History data quality: [\n\(sensor.history.map(\.dataQuality.description).joined(separator: ",\n"))\n]")
////            debugLog("History quality flags: [\(sensor.history.map { "0" + String($0.dataQualityFlags,radix: 2).suffix(2) }.joined(separator: ", "))]")
////        }
////
////        debugLog("Sensor uid: \(sensor.uid.hex), saved uid: \(settings.patchUid.hex), patch info: \(sensor.patchInfo.hex.count > 0 ? sensor.patchInfo.hex : "<nil>"), saved patch info: \(settings.patchInfo.hex)")
////
////        if sensor.uid.count > 0 && sensor.patchInfo.count > 0 {
////            settings.patchUid = sensor.uid
////            settings.patchInfo = sensor.patchInfo
////        }
////
////        if sensor.uid.count == 0 || settings.patchUid.count > 0 {
////            if sensor.uid.count == 0 {
////                sensor.uid = settings.patchUid
////            }
////
////            if sensor.uid == settings.patchUid {
////                sensor.patchInfo = settings.patchInfo
////            }
////        }
////
////        Task {
////
////            didParseSensor(sensor)
////
////        }
////
////    }
////
////
////    func didParseSensor(_ sensor: Sensor?) {
////
////        guard let sensor else {
////            return
////        }
////
////        if history.factoryTrend.count > 0 {
////            app.currentGlucose = history.factoryTrend[0].value
////        }
////
////        let currentGlucose = app.currentGlucose
////
////        // TODO: delete mirrored implementation from Abbott Device
////        // TODO: compute accurate delta and update trend arrow
////        if history.factoryTrend.count > 6 {
////            let deltaMinutes = history.factoryTrend[5].value > 0 ? 5 : 6
////            let delta = (history.factoryTrend[0].value > 0 ? history.factoryTrend[0].value : (history.factoryTrend[1].value > 0 ? history.factoryTrend[1].value : history.factoryTrend[2].value)) - history.factoryTrend[deltaMinutes].value
////            app.trendDeltaMinutes = deltaMinutes
////            app.trendDelta = delta
////        }
////
////        var title = currentGlucose > 0 ? currentGlucose.units : "---"
////
////        let snoozed = settings.lastAlarmDate.timeIntervalSinceNow >= -Double(settings.alarmSnoozeInterval * 60) && settings.disabledNotifications
////
////        if currentGlucose > 0 && (currentGlucose > Int(settings.alarmHigh) || currentGlucose < Int(settings.alarmLow)) {
////            log("ALARM: current glucose: \(currentGlucose.units) (settings: high: \(settings.alarmHigh.units), low: \(settings.alarmLow.units), muted audio: \(settings.mutedAudio ? "yes" : "no")), \(snoozed ? "" : "not ")snoozed")
////
////            if !snoozed {
////                playAlarm()
////                if (settings.calendarTitle == "" || !settings.calendarAlarmIsOn) && !settings.disabledNotifications { // TODO: notifications settings
////                    title += "  \(settings.displayingMillimoles ? GlucoseUnit.mmoll : GlucoseUnit.mgdl)"
////
////                    let alarm = app.glycemicAlarm
////                    if alarm != .unknown {
////                        title += "  \(alarm.shortDescription)"
////                    } else {
////                        if currentGlucose > Int(settings.alarmHigh) {
////                            title += "  HIGH"
////                        }
////                        if currentGlucose < Int(settings.alarmLow) {
////                            title += "  LOW"
////                        }
////                    }
////
////                    let trendArrow = app.trendArrow
////                    if trendArrow != .unknown {
////                        title += "  \(trendArrow.symbol)"
////                    }
////
////                    let content = UNMutableNotificationContent()
////                    content.title = title
////                    content.subtitle = ""
////                    content.sound = UNNotificationSound.default
////                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
////                    let request = UNNotificationRequest(identifier: "DiaBLE", content: content, trigger: trigger)
////                    UNUserNotificationCenter.current().add(request)
////                }
////            }
////        }
////
////        if !settings.disabledNotifications {
////            UNUserNotificationCenter.current().setBadgeCount(
////                settings.displayingMillimoles ? Int(Float(currentGlucose.units)! * 10) : Int(currentGlucose.units)!
////            )
////        } else {
////            UNUserNotificationCenter.current().setBadgeCount(0)
////        }
////
////        eventKit?.sync()
////
////        if !snoozed {
////            settings.lastAlarmDate = Date.now
////        }
////
////        if history.values.count > 0 || history.factoryValues.count > 0 || currentGlucose > 0 {
////            var entries = [Glucose]()
////            if history.values.count > 0 {
////                entries += history.values
////            } else {
////                entries += history.factoryValues
////            }
////            entries += history.factoryTrend.dropFirst() + [Glucose(currentGlucose, date: sensor.lastReadingDate)]
////            entries = entries.filter { $0.value > 0 && $0.id > -1 }
////
////            // TODO
////
////            Task {
////
////                let newEntries = (entries.filter { $0.date > healthKit?.lastDate ?? Calendar.current.date(byAdding: .hour, value: -8, to: Date())! })
////                if newEntries.count > 0 {
////                    healthKit?.write(newEntries)
////                    healthKit?.read()
////                }
////
////                if let (values, _) = try? await nightscout?.read() {
////                    let newEntries = values.count > 0 ? entries.filter { $0.date > values[0].date } : entries
////                    if newEntries.count > 0 {
////                        try await nightscout?.post(entries: newEntries)
////                        if let (values, _) = try? await nightscout?.read() {
////                            history.nightscoutValues = values
////                        }
////                    }
////                }
////            }
////        }
////    }
//}
