//
//  LibreWristApp.swift
//  LibreWrist
//
//  Created by Peter Müller on 29.07.24.
//

import SwiftUI


@main

struct LibreWristApp: App {
        
    init(){
        UserDefaults.group.register(defaults: Settings.defaults)
        print("init")
    }
    
//    @State private var history = History()
    @State private var libreLinkUpHistory = LibreLinkUpHistory.shared
    @State private var sensorSettingsSingleton = SensorSettingsSingleton.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
//                .environment(history)
                .environment(\.libreLinkUpHistory, libreLinkUpHistory)
                .environment(\.sensorSettingsSingleton, sensorSettingsSingleton)
        }
    }
}





