//
//  Glucose.swift
//  LibreWrist
//
//  Created by Peter Müller on 10.09.24.
//

import Foundation


struct Glucose: Identifiable, Codable {

 
    /// id: minutes since sensor start
    let id: Int
    let date: Date
    let rawValue: Int
    let rawTemperature: Int
    let temperatureAdjustment: Int
    let hasError: Bool
    var value: Int = 0
    var temperature: Double = 0
    var trendRate: Double = 0
    var trendArrow: TrendArrow = .stable
    var source: String = "DiaBLE"

    init(rawValue: Int, rawTemperature: Int = 0, temperatureAdjustment: Int = 0, trendRate: Double = 0, trendArrow: TrendArrow = .stable, id: Int = 0, date: Date = Date(), hasError: Bool = false) {
        self.id = id
        self.date = date
        self.rawValue = rawValue
        self.value = rawValue / 10
        self.rawTemperature = rawTemperature
        self.temperatureAdjustment = temperatureAdjustment
        self.trendRate = trendRate
        self.trendArrow = trendArrow
        self.hasError = hasError
    }

    init(bytes: [UInt8], id: Int = 0, date: Date = Date()) {
        let rawValue = Int(bytes[0]) + Int(bytes[1] & 0x1F) << 8
        let rawTemperature = Int(bytes[3]) + Int(bytes[4] & 0x3F) << 8
        // TODO: temperatureAdjustment
        self.init(rawValue: rawValue, rawTemperature: rawTemperature, id: id, date: date)
    }

    init(_ value: Int, temperature: Double = 0, trendRate: Double = 0, trendArrow: TrendArrow = .stable, id: Int = 0, date: Date = Date(), source: String = "DiaBLE") {
        self.init(rawValue: value * 10, id: id, date: date)
        self.temperature = temperature
        self.trendRate = trendRate
        self.trendArrow = trendArrow
        self.source = source
    }

}
