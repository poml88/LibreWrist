//
//  LibreWristWatchApp.swift
//  LibreWristWatch Watch App
//
//  Created by Peter Müller on 26.08.24.
//

import SwiftUI

@main
struct LibreWristWatch_Watch_AppApp: App {
    
    init(){
        UserDefaults.group.register(defaults: Settings.defaults)
        print("init")
    }
    
    @State private var libreLinkUpHistory = LibreLinkUpHistory.shared
    @State private var sensorSettingsSingleton = SensorSettingsSingleton.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.libreLinkUpHistory, libreLinkUpHistory)
                .environment(\.sensorSettingsSingleton, sensorSettingsSingleton)
        }
    }
}

