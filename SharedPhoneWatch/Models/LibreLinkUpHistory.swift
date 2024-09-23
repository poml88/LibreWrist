//
//  LibreLinkUpHistory.swift
//  LibreWrist
//
//  Created by Peter Müller on 10.09.24.
//

import SwiftUI

@Observable class LibreLinkUpHistory {
//    var glucose: [Glucose] = []
//    var color: [MeasurementColor] = []
//    var trendArrow: [TrendArrow?] = []
//    var id: [Glucose.ID] = []
    var libreLinkUpGlucose: [LibreLinkUpGlucose] = []
    var libreLinkUpMinuteGlucose: [LibreLinkUpGlucose] = []
    var lastReadingDate: Date = Date(timeIntervalSinceNow: -999 * 60)
    private init() {}
}

extension LibreLinkUpHistory {
    static let mock: LibreLinkUpHistory = {
//        let libreLinkUpHistory = LibreLinkUpHistory()
//        libreLinkUpHistory.glucose.append(Glucose(rawValue: 1000,
//                                                  rawTemperature: 4,
//                                                  temperatureAdjustment: 4,
//                                                  trendRate: 4.0,
//                                                  trendArrow: .stable,
//                                                  id: 6020,
//                                                  date: Date(timeIntervalSince1970: 746239583),
//                                                  hasError: false))
//        libreLinkUpHistory.color.append(MeasurementColor.green)
//        libreLinkUpHistory.trendArrow.append(TrendArrow(rawValue: 0))
        let libreLinkUpHistory = LibreLinkUpHistory()
        libreLinkUpHistory.libreLinkUpGlucose = [LibreLinkUpGlucose(glucose: Glucose(rawValue: 1000,
                                                                                     rawTemperature: 4,
                                                                                     temperatureAdjustment: 4,
                                                                                     trendRate: 4.0,
                                                                                     trendArrow: .stable,
                                                                                     id: 6020,
                                                                                     date: Date(timeIntervalSinceNow: -3 * 60 * 60),
                                                                                     hasError: false),
                                                                    color: MeasurementColor.green,
                                                                    trendArrow: TrendArrow(rawValue: 0)),
                                                 LibreLinkUpGlucose(glucose: Glucose(rawValue: 1500,
                                                                                     rawTemperature: 4,
                                                                                     temperatureAdjustment: 4,
                                                                                     trendRate: 4.0,
                                                                                     trendArrow: .stable,
                                                                                     id: 6025,
                                                                                     date: Date(timeIntervalSinceNow: -2 * 60 * 60),
                                                                                     hasError: false),
                                                                    color: MeasurementColor.green,
                                                                    trendArrow: TrendArrow(rawValue: 0)),
                                                 LibreLinkUpGlucose(glucose: Glucose(rawValue: 800,
                                                                                     rawTemperature: 4,
                                                                                     temperatureAdjustment: 4,
                                                                                     trendRate: 4.0,
                                                                                     trendArrow: .stable,
                                                                                     id: 6030,
                                                                                     date: Date(timeIntervalSinceNow: -1 * 60 * 60),
                                                                                     hasError: false),
                                                                    color: MeasurementColor.green,
                                                                    trendArrow: TrendArrow(rawValue: 0))]
        
        libreLinkUpHistory.libreLinkUpGlucose = [LibreLinkUpGlucose(glucose: Glucose(rawValue: 1100,
                                                                                     rawTemperature: 4,
                                                                                     temperatureAdjustment: 4,
                                                                                     trendRate: 4.0,
                                                                                     trendArrow: .stable,
                                                                                     id: 6020,
                                                                                     date: Date(timeIntervalSinceNow: -3 * 60 * 60),
                                                                                     hasError: false),
                                                                    color: MeasurementColor.green,
                                                                    trendArrow: TrendArrow(rawValue: 0)),
                                                 LibreLinkUpGlucose(glucose: Glucose(rawValue: 1400,
                                                                                     rawTemperature: 4,
                                                                                     temperatureAdjustment: 4,
                                                                                     trendRate: 4.0,
                                                                                     trendArrow: .stable,
                                                                                     id: 6025,
                                                                                     date: Date(timeIntervalSinceNow: -2 * 60 * 60),
                                                                                     hasError: false),
                                                                    color: MeasurementColor.green,
                                                                    trendArrow: TrendArrow(rawValue: 0)),
                                                 LibreLinkUpGlucose(glucose: Glucose(rawValue: 900,
                                                                                     rawTemperature: 4,
                                                                                     temperatureAdjustment: 4,
                                                                                     trendRate: 4.0,
                                                                                     trendArrow: .stable,
                                                                                     id: 6030,
                                                                                     date: Date(timeIntervalSinceNow: -1 * 60 * 60),
                                                                                     hasError: false),
                                                                    color: MeasurementColor.green,
                                                                    trendArrow: TrendArrow(rawValue: 0))]
        
        return libreLinkUpHistory
    }()
    
}

extension EnvironmentValues {
    var libreLinkUpHistory: LibreLinkUpHistory {
        get { self[LibreLinkUpHistoryKey.self] }
        set { self[LibreLinkUpHistoryKey.self] = newValue }
    }
}


private struct LibreLinkUpHistoryKey: EnvironmentKey {
    static var defaultValue: LibreLinkUpHistory = LibreLinkUpHistory.mock
}

