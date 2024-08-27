//
//  ContentView.swift
//  LibreWrist
//
//  Created by Peter Müller on 29.07.24.
//

import SwiftUI
import OSLog

struct ContentView: View {
    
    @State var selectedTab = "Home"
    
    var body: some View {
        TabView (selection:$selectedTab){
            
            PhoneAppHomeView()
                .tabItem { 
                    Image(systemName: "house")
                    Text ("Tab 1")
                }
                .tag("Home")
            
            
            PhoneAppSetupView()
                .tabItem {
                    Image(systemName: "gear")
                    Text ("Tab 2")
                }
                .tag("Setup")
            
            PhoneAppDonateView()
                .tabItem {
                    Image(systemName: "banknote")
                    Text ("Tab 3")
                }
                .tag("Donate")
        }
        .padding()
    }
}



#Preview {
    ContentView()
        .environment(History.test)
}
