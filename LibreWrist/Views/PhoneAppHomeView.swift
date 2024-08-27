//
//  PhoneAppHomeView.swift
//  LibreWrist
//
//  Created by Peter Müller on 31.07.24.
//

import SwiftUI
import OSLog
import Charts



struct PhoneAppHomeView: View {
    
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    @Environment(\.scenePhase) var scenePhase
    @Environment(History.self) var history: History
    
    
    @State private var selectedlibreLinkHistoryPoint: LibreLinkUpGlucose?
    @State private var minutesSinceLastReading: Int = 999
    @State private var libreLinkUpResponse: String = "[...]"
    @State private var libreLinkUpHistory: [LibreLinkUpGlucose] = MockDataPhone
    @State private var libreLinkUpLogbookHistory: [LibreLinkUpGlucose] = []
    
    @State var lastReadingDate: Date = Date.distantPast
    @State var sensor: Sensor!
    @State var currentGlucose: Int = 0
    @State var trendArrow = "---"
    
    
    var body: some View {
        VStack {
            HStack {
                Text("\(currentGlucose)")
                    .font(.system(size: 96, weight: .bold))
                VStack {
                    Text("\(trendArrow)")
                        .font(.system(size: 50, weight: .bold))
                    Text("\(lastReadingDate.toLocalTime())")
                        .font(.system(size: 30, weight: .bold))
                    
                    if minutesSinceLastReading == 999 {
                        Text("-- min ago")
                    } else {
                        Text("\(minutesSinceLastReading) min ago")
                            .font(.footnote)
                            .monospacedDigit()
                            .onReceive(timer) { _ in
                                minutesSinceLastReading = Int(Date().timeIntervalSince(lastReadingDate) / 60)
                            }
                    }
                }
            }
            
            if libreLinkUpHistory.count > 0 {
                
                let rectXStart: Date = libreLinkUpHistory.last?.glucose.date ?? Date.distantPast
                let rectXStop: Date = libreLinkUpHistory.first?.glucose.date ?? Date.distantFuture
                
                Chart {
                    //                    RuleMark(y: .value("Minimum High", 300))
                    //                        .foregroundStyle(.clear)
                    
                    RuleMark(y: .value("Lower limit", 85))
                        .foregroundStyle(.red)
                        .lineStyle(.init(lineWidth: 1, dash: [2]))
                    
                    RuleMark(y: .value("Upper limit", 300))
                        .foregroundStyle(.red)
                        .lineStyle(.init(lineWidth: 1, dash: [2]))
                    
                    RectangleMark(
                        xStart: .value("Rect Start Width", rectXStart),
                        xEnd: .value("Rect End Width", rectXStop),
                        yStart: .value("Rect Start Height", 70),
                        yEnd: .value("Rect End Height", 180)
                    )
                    .opacity(0.2)
                    .foregroundStyle(.green)
                    
                    
                    ForEach(libreLinkUpHistory) { item in
                        
                        PointMark(x: .value("Time", item.glucose.date),
                                  y: .value("Glucose", item.glucose.value)
                        )
                        .foregroundStyle(.red)
                        .symbolSize(12)
                        
                        LineMark(x: .value("Time", item.glucose.date),
                                 y: .value("Glucose", item.glucose.value))
                        .interpolationMethod(.linear)
                        .lineStyle(.init(lineWidth: 5))
                        
                        
                        if let selectedlibreLinkHistoryPoint,selectedlibreLinkHistoryPoint.id == item.id {
                            RuleMark(x: .value("Time", selectedlibreLinkHistoryPoint.glucose.date))
                                .annotation(position: .top) {
                                    VStack(alignment: .leading, spacing: 6){
                                        Text("\(selectedlibreLinkHistoryPoint.glucose.date.toLocalTime())")
                                        
                                        Text("\(selectedlibreLinkHistoryPoint.glucose.value) mg/dL")
                                            .font(.title3.bold())
                                    }
                                    .padding(.horizontal,10)
                                    .padding(.vertical,4)
                                    .background{
                                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                                            .fill(.background.shadow(.drop(radius: 2)))
                                    }
                                }
                        }
                    }
                    
                    ForEach(history.factoryTrend) { item in
                        PointMark(x: .value("Time", item.date),
                                  y: .value("Glucose", item.value)
                        )
                        .foregroundStyle(.yellow)
                        .symbolSize(6)
                        
                    }
                }
                .chartYScale(domain: [0, 350])
                .chartXAxis {
                    AxisMarks(values: .stride(by: .hour, count: 3)) { _ in
                        AxisGridLine(stroke: .init(lineWidth: 0.5, dash: [2, 3]))
                        AxisTick(length: -5, stroke: .init(lineWidth: 1))
                            .foregroundStyle(.gray)
                        //                        AxisValueLabel( anchor: .top)
                        AxisValueLabel(format: .dateTime.hour(.defaultDigits(amPM: .narrow)), anchor: .top)
                    }
                    AxisMarks(values: .stride(by: .hour, count: 1)) { _ in
                        //                        AxisGridLine(stroke: .init(lineWidth: 0.5, dash: [2, 3]))
                        AxisTick(length: -5, stroke: .init(lineWidth: 1))
                            .foregroundStyle(.gray)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .trailing, values: .stride(by: 50)) { value in
                        AxisGridLine(stroke: .init(lineWidth: 0.5))
                        //                        AxisTick(length: 5, stroke: .init(lineWidth: 1))
                            .foregroundStyle(.gray)
                        AxisValueLabel()
                        
                    }
                }
                .chartOverlay { overlayProxy in
                    GeometryReader { geometryProxy in
                        Rectangle().fill(.clear).contentShape(Rectangle())
                            .gesture(DragGesture()
                                .onChanged { value in
                                    let currentX = value.location
                                    if let currentDate: Date = overlayProxy.value(atX: currentX.x) {
                                        //                                        let selectedlibreLinkHistoryPoint = libreLinkUpHistory[currentDate.toRounded(on: 1, .minute)]
                                        if let currentItem = libreLinkUpHistory.first(where: { item in
                                            item.glucose.date.toRounded(on: 1, .minute) == currentDate.toRounded(on: 1, .minute)
                                        }){
                                            self.selectedlibreLinkHistoryPoint = currentItem
                                        }                                     }
                                }
                                     
                                .onEnded { value in
                                    self.selectedlibreLinkHistoryPoint = nil
                                }
                            )
                    }
                }
                .padding()
            }
        }
        
        .onReceive(timer) { time in
            print("Timer")
            Task {
                await reloadLibreLinkUp()
            }
        }
        .onAppear() {
            print("onAppear")
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                print("Active")
                Task {
                    await reloadLibreLinkUp()
                }
            } else if newPhase == .inactive {
                print("Inactive")
            } else if newPhase == .background {
                print("Background")
            }
        }
    }
    
    
    func reloadLibreLinkUp() async {
        
        var dataString = ""
        var retries = 0
        
        
    loop: repeat {
        do {
            let token = settings.libreLinkUpToken
            print("token!!!"); print(token)
            if settings.libreLinkUpUserId.isEmpty ||
                settings.libreLinkUpToken.isEmpty ||
                settings.libreLinkUpTokenExpirationDate < Date() ||
                retries == 1 {
                do {
                    try await LibreLinkUp().login()
                } catch {
                    libreLinkUpResponse = error.localizedDescription.capitalized
                }
            }
            if !(settings.libreLinkUpUserId.isEmpty ||
                 settings.libreLinkUpToken.isEmpty) {
                let (data, _, graphHistory, logbookData, logbookHistory, _) = try await LibreLinkUp().getPatientGraph()
                dataString = (data as! Data).string
                libreLinkUpResponse = dataString + (logbookData as! Data).string
                // TODO: just merge with newer values
                libreLinkUpHistory = graphHistory.reversed()
                
                print(libreLinkUpHistory)
                libreLinkUpLogbookHistory = logbookHistory
                if graphHistory.count > 0 {
                    DispatchQueue.main.async {
                        settings.lastOnlineDate = Date()
                        let lastMeasurement = libreLinkUpHistory[0]
                        lastReadingDate = lastMeasurement.glucose.date
                        minutesSinceLastReading = Int(Date().timeIntervalSince(lastReadingDate) / 60)
                        sensor?.lastReadingDate = lastReadingDate
                        currentGlucose = lastMeasurement.glucose.value
                        trendArrow = lastMeasurement.trendArrow?.symbol ?? "---"
                        // TODO: keep the raw values filling the gaps with -1 values
                        history.rawValues = []
                        history.factoryValues = libreLinkUpHistory.dropFirst().map(\.glucose) // TEST
                        var trend = history.factoryTrend
                        if trend.isEmpty || lastMeasurement.id > trend[0].id {
                            trend.insert(lastMeasurement.glucose, at: 0)
                        }
                        // keep only the latest 22 minutes considering the 17-minute latency of the historic values update
                        trend = trend.filter { lastMeasurement.id - $0.id < 22 }
                        history.factoryTrend = trend
                        Logger.general.info("LibreLinkUp: history.factoryTrend: \(history.factoryTrend)")
                        // TODO: merge and update sensor history / trend
                        //                            app.main.didParseSensor(app.sensor)
                    }
                }
                if dataString != "{\"message\":\"MissingCachedUser\"}\n" {
                    break loop
                }
                retries += 1
            }
        } catch {
            libreLinkUpResponse = error.localizedDescription.capitalized
        }
    } while retries == 1
        
    }
}




#Preview {
    PhoneAppHomeView()
        .environment(History.test)
}


struct MockData {
    
    static let libreLinkUpHistory = [LibreLinkUpGlucose(glucose: Glucose(rawValue: 1200, rawTemperature: 4, temperatureAdjustment: 4, trendRate: 4.0, trendArrow: 4, id: 4, date: Date(timeIntervalSince1970: 746277263), hasError: false, dataQuality: Glucose.DataQuality.OK, dataQualityFlags: 3),
                                                        color: MeasurementColor.green,
                                                        trendArrow: TrendArrow(rawValue: 0))]
    
    let test = Glucose(rawValue: 4, rawTemperature: 4, temperatureAdjustment: 4, trendRate: 4.0, trendArrow: 4, id: 4, date: Date(timeIntervalSince1970: 345345345), hasError: false, dataQuality: Glucose.DataQuality.OK, dataQualityFlags: 3)
    let test2 = Glucose(120, temperature: 20.0, trendRate: 0.0, trendArrow: 0, id: 6000, date: Date(), dataQuality: Glucose.DataQuality.OK, source: "Mock")
}

let MockDataPhone = [LibreLinkUpGlucose(glucose: Glucose(rawValue: 1000,
                                                         rawTemperature: 4,
                                                         temperatureAdjustment: 4,
                                                         trendRate: 4.0,
                                                         trendArrow: 4,
                                                         id: 6020,
                                                         date: Date(timeIntervalSince1970: 746239583),
                                                         hasError: false,
                                                         dataQuality: Glucose.DataQuality.OK,
                                                         dataQualityFlags: 3),
                                        color: MeasurementColor.green,
                                        trendArrow: TrendArrow(rawValue: 0)),
                     LibreLinkUpGlucose(glucose: Glucose(rawValue: 1500,
                                                         rawTemperature: 4,
                                                         temperatureAdjustment: 4,
                                                         trendRate: 4.0,
                                                         trendArrow: 4,
                                                         id: 6025,
                                                         date: Date(timeIntervalSince1970: 746260584),
                                                         hasError: false,
                                                         dataQuality: Glucose.DataQuality.OK,
                                                         dataQualityFlags: 3),
                                        color: MeasurementColor.green,
                                        trendArrow: TrendArrow(rawValue: 0)),
                     LibreLinkUpGlucose(glucose: Glucose(rawValue: 800,
                                                         rawTemperature: 4,
                                                         temperatureAdjustment: 4,
                                                         trendRate: 4.0,
                                                         trendArrow: 4,
                                                         id: 6030,
                                                         date: Date(timeIntervalSince1970: 746282663),
                                                         hasError: false,
                                                         dataQuality: Glucose.DataQuality.OK,
                                                         dataQualityFlags: 3),
                                        color: MeasurementColor.green,
                                        trendArrow: TrendArrow(rawValue: 0))]

