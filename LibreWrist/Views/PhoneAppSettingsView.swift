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
            }
            
            
        header: {
            Text("Settings")
        }
            
        }
    }
}

#Preview {
    PhoneAppSettingsView()
}



