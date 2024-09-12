//
//  LibreLinkUpAlarm.swift
//  LibreWrist
//
//  Created by Peter Müller on 10.09.24.
//

import Foundation

struct LibreLinkUpAlarm: Identifiable, Codable, CustomStringConvertible {
    let factoryTimestamp: String
    let timestamp: String
    let type: Int  // 2 (1 for measurements)
    let alarmType: Int  // 0: low, 1: high, 2: fixedLow
    enum CodingKeys: String, CodingKey { case factoryTimestamp = "FactoryTimestamp", timestamp = "Timestamp", type, alarmType }
    var id: Int { Int(date.timeIntervalSince1970) }
    var date: Date = Date()
    var alarmDescription: String { alarmType == 1 ? "HIGH" : "LOW" }
    var description: String { "\(date): \(alarmDescription)" }
}
