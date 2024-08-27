//
//  ContentView.swift
//  LibreWristWatch Watch App
//
//  Created by Peter Müller on 26.08.24.
//

import SwiftUI


struct ContentView: View {
    
    @State var selected = "Home"
    

        var body: some View {
            TabView(selection: $selected) {
                WatchAppHomeView()
                    .tag("Home")
                WatchAppSettingsView()
                    .tag("Settings")
                WatchAppNightView()
                    .tag("NightView")
                
            }
            .tabViewStyle(.page)
        }
    }


#Preview {
    ContentView()
}
