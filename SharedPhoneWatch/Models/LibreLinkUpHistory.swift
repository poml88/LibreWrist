//
//  LibreLinkUpHistory.swift
//  LibreWrist
//
//  Created by Peter Müller on 10.09.24.
//

import Foundation

@Observable class LibreLinkUpHistory {
//    var glucose: [Glucose] = []
//    var color: [MeasurementColor] = []
//    var trendArrow: [TrendArrow?] = []
//    var id: [Glucose.ID] = []
    var libreLinkUpGlucose: [LibreLinkUpGlucose] = []
}

extension LibreLinkUpHistory {
    static var mock: LibreLinkUpHistory {
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
        libreLinkUpHistory.libreLinkUpGlucose.append(LibreLinkUpGlucose(glucose: Glucose(rawValue: 1000,
                                                                                         rawTemperature: 4,
                                                                                         temperatureAdjustment: 4,
                                                                                         trendRate: 4.0,
                                                                                         trendArrow: .stable,
                                                                                         id: 6020,
                                                                                         date: Date(timeIntervalSince1970: 746239583),
                                                                                         hasError: false),
                                                                        color: MeasurementColor.green,
                                                                        trendArrow: TrendArrow(rawValue: 0)))
        return libreLinkUpHistory
    }
    
}
