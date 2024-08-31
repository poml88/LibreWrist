//
//  WatchAppSettings2View.swift
//  LibreWristWatch Watch App
//
//  Created by Peter Müller on 30.08.24.
//

import SwiftUI



struct WatchAppSettings2View: View {
    
    @State var durationInsulinActivity: String = "4.5"
    
    
    var body: some View {
        Form {Section(header: Text("Settings")) {
            TextField("Duration of insulin activity", text: $durationInsulinActivity)
        }
        }
    }
}

#Preview {
    WatchAppSettings2View()
}
