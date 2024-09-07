//
//  WatchAppSettings2View.swift
//  LibreWristWatch Watch App
//
//  Created by Peter Müller on 30.08.24.
//

import SwiftUI



struct WatchAppDonateView: View {
    var body: some View {
        VStack {
            Text("If you like this app...\n🙂\n Please Donate!\n💪🤝💰")
                .font(.caption)
                .multilineTextAlignment(.center)
                .padding()
            
            
                Text("paypal.me/lovemyhusky")
                .font(.caption)
                    .frame(maxWidth: 200, maxHeight: 50)
                    .foregroundColor(.black)
                    .background(.green)
                    .cornerRadius(10)
            
        }
    }
}

#Preview {
    WatchAppDonateView()
}
