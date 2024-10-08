//
//  PhoneAppSettingsView.swift
//  LibreWrist
//
//  Created by Peter Müller on 03.09.24.
//

import SwiftUI

struct PhoneAppSettingsView: View {
    
    @State private var isScreenAlwaysOn = false
    
    var body: some View {
        Form {
            Section {
                
                Toggle("Keep phone screen always on", isOn: $isScreenAlwaysOn)
                    .onChange(of: isScreenAlwaysOn) { value in
                        print("yes")
                        UIApplication.shared.isIdleTimerDisabled.toggle()
                    }
            } header: {
            Text("Settings")
        }
            
            Section {
                let versionNumber: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
                let buildNumber: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
                Text("V\(versionNumber).\(buildNumber)")
                
                let systemVersion = UIDevice.current.systemVersion
                let systemName = UIDevice.current.systemName
                let model = UIDevice.current.model
                let name = UIDevice.current.name
                Text("\(systemName) \(systemVersion) on \(name)")

                
                Link(destination: URL(string: "https://github.com/poml88/LibreWrist/issues")!) {
                    Text("Open issue on GitHub")
                        .frame(width: 200, height: 50)
                        .foregroundColor(.primary)
                        .background(.primary)
                        .cornerRadius(10)
                }
               
            } header: {
            Text("Debug Info")
        }
            
        }
    }
}

#Preview {
    PhoneAppSettingsView()
}



