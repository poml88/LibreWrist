//
//  WatchAppNightView.swift
//  LibreWristWatch Watch App
//
//  Created by Peter Müller on 26.08.24.
//

import SwiftUI

 
struct WatchAppNightView: View {
    
    @Environment(\.libreLinkUpHistory) var libreLinkUpHistory
    
    @State private var currentIOB: Double = 0.0
    
    var body: some View {
        if libreLinkUpHistory.libreLinkUpGlucose.count > 0 {
            VStack {
    //                if minutesSinceLastReading >= 3 {
    //                    Text("---")
    //                    .font(.system(size: 60)) //, weight: .bold
    //                    .minimumScaleFactor(0.1)
    //                    .padding()
    //                } else {
                Text("\(libreLinkUpHistory.libreLinkUpGlucose[0].glucose.value)")
                    .font(.system(size: 100)) //, weight: .bold
                    .foregroundStyle(libreLinkUpHistory.libreLinkUpGlucose[0].color.color)
                        .minimumScaleFactor(0.9)
    //                    .padding()
    //                }
                    
                VStack (spacing: -10){
    //                    if minutesSinceLastReading >= 3 {
    //                        Text("---")
    //                            .font(.title)
    //                    } else {
                    Text("\(libreLinkUpHistory.libreLinkUpGlucose[0].trendArrow?.symbol ?? "--")")
                        .font(.system(size: 100)) //, weight: .bold
                        .foregroundStyle(libreLinkUpHistory.libreLinkUpGlucose[0].color.color)
                            .minimumScaleFactor(0.7)
    //                        .foregroundStyle(libreLinkUpHistory[0].color.color)
                    
    //                Text("\(currentIOB, specifier: "%.2f")U")
    //                    .font(.body)
                    
    //                    }
                    //                    Text("\(lastReadingDate.toLocalTime())")
                    //                        .font(.system(size: 30, weight: .bold))
                    
    //                    if minutesSinceLastReading == 999 {
    //                        Text("-- min ago")
    //                    } else {
    //                        Text("\(minutesSinceLastReading) min ago")
    //                    }
                }
                .padding()
            }
            .overlay {
                if Int(Date().timeIntervalSince(LibreLinkUpHistory.shared.lastReadingDate) / 60) >= 3 {
                    ZStack {
                        Color(white: 0, opacity: 0.5)
                        
                        VStack {
                            Image(systemName: "hourglass.circle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40)
                            
                            Text("No data since \(Int(Date().timeIntervalSince(LibreLinkUpHistory.shared.lastReadingDate) / 60)) min.")
                                .multilineTextAlignment(.center)
                        }
                        
                        
                    }
                    .ignoresSafeArea()
                }
            }
        }

    }
 
}



#Preview {
    WatchAppNightView()
//        .environment(History.test)
}
