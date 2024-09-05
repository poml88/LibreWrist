//
//  SensorSettings.swift
//  LibreWrist
//
//  Created by Peter Müller on 05.09.24.
//

import Foundation


@Observable class SensorSettings {
    let uom: Int
    let targetLow: Int
    let targetHigh: Int
    let alarmLow: Int
    let alarmHigh: Int
    
    init(uom: Int, targetLow: Int, targetHigh: Int, alarmLow: Int, alarmHigh: Int) {
        self.uom = uom
        self.targetLow = targetLow
        self.targetHigh = targetHigh
        self.alarmLow = alarmLow
        self.alarmHigh = alarmHigh
    }
}

//var sensorSettings = SensorSettings(uom: 1, targetLow: 70, targetHigh: 180, alarmLow: 80, alarmHigh: 300)


