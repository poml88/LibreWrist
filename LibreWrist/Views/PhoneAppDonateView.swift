//
//  PhoneAppDonateView.swift
//  LibreWrist
//
//  Created by Peter Müller on 01.08.24.
//

import SwiftUI

struct PhoneAppDonateView: View {
    var body: some View {
        VStack {
            Text("If you like this app...\n🙂\n Please Donate! 💪🤝💰")
                .multilineTextAlignment(.center)
                .padding()
            
            Link(destination: URL(string: "https://paypal.me/lovemyhusky")!) {
                
                    
                    Text("💰 Paypal Me")
                
                .frame(width: 200, height: 50)
                .foregroundColor(.primary)
                .background(.primary)
                .cornerRadius(10)
                
            }
            
        }
        
    }
}

#Preview {
    PhoneAppDonateView()
}
