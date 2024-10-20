//
//  SensorSettings.swift
//  LibreWrist
//
//  Created by Peter Müller on 05.09.24.
//

import SwiftUI


struct SensorSettings {
    let uom: Int
    let targetLow: Int
    let targetHigh: Int
    let alarmLow: Int
    let alarmHigh: Int
    
    init(uom: Int = 1, targetLow: Int = 70, targetHigh: Int = 180, alarmLow: Int = 80, alarmHigh: Int = 300) {
        self.uom = uom
        self.targetLow = targetLow
        self.targetHigh = targetHigh
        self.alarmLow = alarmLow
        self.alarmHigh = alarmHigh
    }
}


@Observable class SensorSettingsSingleton {
    
    var sensorSettings: SensorSettings = SensorSettings()
    var sensorType: SensorType = .unknown
    
    static let shared: SensorSettingsSingleton = {
        let instance = SensorSettingsSingleton()
        //nothing at the moment
        return instance
    }()
    
    private init(){}
}
    
extension EnvironmentValues {
    var sensorSettingsSingleton: SensorSettingsSingleton {
        get { self[SensorSettingsSingletonKey.self] }
        set { self[SensorSettingsSingletonKey.self] = newValue }
    }
}


private struct SensorSettingsSingletonKey: EnvironmentKey {
    static var defaultValue: SensorSettingsSingleton = SensorSettingsSingleton.shared
}


//var sensorSettings = SensorSettings(uom: 1, targetLow: 70, targetHigh: 180, alarmLow: 80, alarmHigh: 300)


