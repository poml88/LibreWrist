//
//  WatchAppNightView.swift
//  LibreWristWatch Watch App
//
//  Created by Peter Müller on 26.08.24.
//

import SwiftUI

 
struct WatchAppNightView: View {
    
    @Environment(History.self) var history: History
    
    var body: some View {
        HStack {
//                if minutesSinceLastReading >= 3 {
//                    Text("---")
//                    .font(.system(size: 60)) //, weight: .bold
//                    .minimumScaleFactor(0.1)
//                    .padding()
//                } else {
            Text("\(history.factoryTrend[0].value)")
                .font(.system(size: 60)) //, weight: .bold
//                .foregroundStyle(libreLinkUpHistory[0].color.color)
                    .minimumScaleFactor(0.1)
                    .padding()
//                }
                
            VStack (spacing: -10){
//                    if minutesSinceLastReading >= 3 {
//                        Text("---")
//                            .font(.title)
//                    } else {
                Text("\(history.factoryTrend[0].trendArrow)")
                        .font(.title)
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
    }
}

#Preview {
    WatchAppNightView()
}
