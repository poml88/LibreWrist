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
    @State private var minutesSinceLastReading: Int = 0
    @State private var libreLinkUpResponse: String = "[...]"
    @State private var libreLinkUpHistory: [LibreLinkUpGlucose] = [LibreLinkUpGlucose(glucose: Glucose(rawValue: 1000,
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
    @State private var libreLinkUpLogbookHistory: [LibreLinkUpGlucose] = []
    
    @State var lastReadingDate: Date = Date.distantPast
    @State var sensor: Sensor!
    @State var currentGlucose: Int = 0
    
    @State var trendArrow = "---"
    
    
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
    
    var body: some View {
        VStack{
            HStack{
                Text("\(currentGlucose)")
                    .font(.system(size: 96, weight: .bold))
                VStack{
                    Text("\(trendArrow)")
                        .font(.system(size: 50, weight: .bold))
                    Text("\(lastReadingDate.toLocalTime())")
                        .font(.system(size: 30, weight: .bold))
                    
                    Text("\(minutesSinceLastReading) min ago")
                        .font(.footnote)
                        .monospacedDigit()
                        .onReceive(timer) { _ in
                            minutesSinceLastReading = Int(Date().timeIntervalSince(lastReadingDate) / 60)
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
                
//                .chartOverlay { overlayProxy in
//                    GeometryReader { geometryProxy in
//                        Rectangle().fill(.clear).contentShape(Rectangle())
//                            .gesture(DragGesture()
//                                .onChanged { value in
//                                    let currentX = value.location.x - geometryProxy[overlayProxy.plotAreaFrame].origin.x
//
//                                    if let currentDate: Date = overlayProxy.value(atX: currentX) {
//                                        let selectedSmoothSensorPoint = smoothSensorPointInfos[currentDate.toRounded(on: 1, .minute)]
//                                        let selectedRawSensorPoint = rawSensorPointInfos[currentDate.toRounded(on: 1, .minute)]
//                                        let selectedBloodPoint = bloodPointInfos[currentDate.toRounded(on: 1, .minute)]
//
//                                        if let selectedSmoothSensorPoint {
//                                            self.selectedSmoothSensorPoint = selectedSmoothSensorPoint
//                                        }
//
//                                        self.selectedRawSensorPoint = selectedRawSensorPoint
//                                        self.selectedBloodPoint = selectedBloodPoint
//                                    }
//                                }
//                                .onEnded { _ in
//                                    selectedSmoothSensorPoint = nil
//                                    selectedRawSensorPoint = nil
//                                    selectedBloodPoint = nil
//                                }
//                            )
//                    }
//                }
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
    
    //    let id: Int
    //    let date: Date
    //    let rawValue: Int
    //    let rawTemperature: Int
    //    let temperatureAdjustment: Int
    //    let hasError: Bool
    //    let dataQuality: DataQuality
    //    let dataQualityFlags: Int
    //    var value: Int = 0
    //    var temperature: Double = 0
    //    var trendRate: Double = 0
    //    var trendArrow: Int = 0  // TODO: enum
    //    var source: String = "DiaBLE"
    
    //    static let libreLinkUpHistory = [LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6632, date: 2024-08-25 10:57:24 +0000, rawValue: 1200, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 120, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: Optional(STABLE)), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6610, date: 2024-08-25 10:36:24 +0000, rawValue: 1250, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 125, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6605, date: 2024-08-25 10:31:24 +0000, rawValue: 1260, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 126, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6600, date: 2024-08-25 10:26:23 +0000, rawValue: 1270, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 127, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6595, date: 2024-08-25 10:21:23 +0000, rawValue: 1290, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 129, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6590, date: 2024-08-25 10:16:24 +0000, rawValue: 1310, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 131, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6585, date: 2024-08-25 10:11:23 +0000, rawValue: 1340, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 134, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6580, date: 2024-08-25 10:06:24 +0000, rawValue: 1350, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 135, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6575, date: 2024-08-25 10:01:23 +0000, rawValue: 1370, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 137, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6570, date: 2024-08-25 09:56:24 +0000, rawValue: 1390, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 139, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6565, date: 2024-08-25 09:51:24 +0000, rawValue: 1380, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 138, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6560, date: 2024-08-25 09:46:23 +0000, rawValue: 1380, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 138, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6555, date: 2024-08-25 09:41:23 +0000, rawValue: 1350, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 135, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6550, date: 2024-08-25 09:36:23 +0000, rawValue: 1330, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 133, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6545, date: 2024-08-25 09:31:24 +0000, rawValue: 1320, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 132, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6540, date: 2024-08-25 09:26:23 +0000, rawValue: 1330, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 133, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6535, date: 2024-08-25 09:21:23 +0000, rawValue: 1330, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 133, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6530, date: 2024-08-25 09:16:23 +0000, rawValue: 1320, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 132, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6525, date: 2024-08-25 09:11:24 +0000, rawValue: 1350, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 135, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6520, date: 2024-08-25 09:06:24 +0000, rawValue: 1410, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 141, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6515, date: 2024-08-25 09:01:23 +0000, rawValue: 1500, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 150, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6510, date: 2024-08-25 08:56:24 +0000, rawValue: 1540, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 154, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6505, date: 2024-08-25 08:51:24 +0000, rawValue: 1610, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 161, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6500, date: 2024-08-25 08:46:35 +0000, rawValue: 1730, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 173, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6495, date: 2024-08-25 08:41:24 +0000, rawValue: 1790, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 179, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6490, date: 2024-08-25 08:36:23 +0000, rawValue: 1800, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 180, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6485, date: 2024-08-25 08:31:33 +0000, rawValue: 1750, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 175, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6480, date: 2024-08-25 08:26:25 +0000, rawValue: 1600, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 160, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6475, date: 2024-08-25 08:21:23 +0000, rawValue: 1580, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 158, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6470, date: 2024-08-25 08:16:25 +0000, rawValue: 1560, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 156, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6465, date: 2024-08-25 08:11:24 +0000, rawValue: 1540, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 154, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6460, date: 2024-08-25 08:06:24 +0000, rawValue: 1530, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 153, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6455, date: 2024-08-25 08:01:23 +0000, rawValue: 1490, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 149, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6450, date: 2024-08-25 07:56:24 +0000, rawValue: 1460, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 146, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6445, date: 2024-08-25 07:51:25 +0000, rawValue: 1440, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 144, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6440, date: 2024-08-25 07:46:25 +0000, rawValue: 1360, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 136, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6435, date: 2024-08-25 07:41:24 +0000, rawValue: 1340, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 134, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6430, date: 2024-08-25 07:36:23 +0000, rawValue: 1310, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 131, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6425, date: 2024-08-25 07:31:24 +0000, rawValue: 1280, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 128, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6420, date: 2024-08-25 07:26:24 +0000, rawValue: 1270, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 127, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6415, date: 2024-08-25 07:21:37 +0000, rawValue: 1260, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 126, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6410, date: 2024-08-25 07:16:37 +0000, rawValue: 1260, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 126, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6405, date: 2024-08-25 07:11:37 +0000, rawValue: 1290, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 129, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6400, date: 2024-08-25 07:06:24 +0000, rawValue: 1290, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 129, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6395, date: 2024-08-25 07:01:24 +0000, rawValue: 1270, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 127, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6390, date: 2024-08-25 06:56:24 +0000, rawValue: 1260, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 126, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6385, date: 2024-08-25 06:51:24 +0000, rawValue: 1210, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 121, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6380, date: 2024-08-25 06:46:24 +0000, rawValue: 1220, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 122, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6375, date: 2024-08-25 06:41:25 +0000, rawValue: 1200, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 120, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6370, date: 2024-08-25 06:36:24 +0000, rawValue: 1180, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 118, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6365, date: 2024-08-25 06:31:24 +0000, rawValue: 1170, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 117, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6360, date: 2024-08-25 06:26:25 +0000, rawValue: 1160, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 116, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6355, date: 2024-08-25 06:21:23 +0000, rawValue: 1190, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 119, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6350, date: 2024-08-25 06:16:23 +0000, rawValue: 1190, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 119, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6345, date: 2024-08-25 06:11:24 +0000, rawValue: 1200, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 120, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6340, date: 2024-08-25 06:06:24 +0000, rawValue: 1190, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 119, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6335, date: 2024-08-25 06:01:24 +0000, rawValue: 1180, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 118, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6330, date: 2024-08-25 05:56:25 +0000, rawValue: 1150, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 115, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6325, date: 2024-08-25 05:51:25 +0000, rawValue: 1150, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 115, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6320, date: 2024-08-25 05:46:24 +0000, rawValue: 1160, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 116, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6315, date: 2024-08-25 05:41:23 +0000, rawValue: 1130, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 113, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6310, date: 2024-08-25 05:36:23 +0000, rawValue: 1130, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 113, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6305, date: 2024-08-25 05:31:23 +0000, rawValue: 1130, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 113, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6300, date: 2024-08-25 05:26:25 +0000, rawValue: 1090, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 109, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6295, date: 2024-08-25 05:21:24 +0000, rawValue: 1080, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 108, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6290, date: 2024-08-25 05:16:24 +0000, rawValue: 1050, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 105, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6285, date: 2024-08-25 05:11:24 +0000, rawValue: 1040, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 104, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6280, date: 2024-08-25 05:06:23 +0000, rawValue: 1040, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 104, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6275, date: 2024-08-25 05:01:25 +0000, rawValue: 1020, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 102, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6270, date: 2024-08-25 04:56:24 +0000, rawValue: 1020, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 102, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6265, date: 2024-08-25 04:51:25 +0000, rawValue: 1020, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 102, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6260, date: 2024-08-25 04:46:24 +0000, rawValue: 1030, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 103, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6255, date: 2024-08-25 04:41:24 +0000, rawValue: 1050, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 105, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6250, date: 2024-08-25 04:36:24 +0000, rawValue: 1060, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 106, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6245, date: 2024-08-25 04:31:24 +0000, rawValue: 1050, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 105, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6240, date: 2024-08-25 04:26:24 +0000, rawValue: 1050, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 105, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6235, date: 2024-08-25 04:21:24 +0000, rawValue: 1050, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 105, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6230, date: 2024-08-25 04:16:24 +0000, rawValue: 1050, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 105, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6225, date: 2024-08-25 04:11:25 +0000, rawValue: 1040, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 104, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6220, date: 2024-08-25 04:06:23 +0000, rawValue: 1010, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 101, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6215, date: 2024-08-25 04:01:25 +0000, rawValue: 1000, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 100, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6210, date: 2024-08-25 03:56:23 +0000, rawValue: 1010, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 101, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6205, date: 2024-08-25 03:51:25 +0000, rawValue: 1010, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 101, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6200, date: 2024-08-25 03:46:24 +0000, rawValue: 1000, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 100, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6195, date: 2024-08-25 03:41:24 +0000, rawValue: 1000, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 100, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6190, date: 2024-08-25 03:36:24 +0000, rawValue: 1010, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 101, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6185, date: 2024-08-25 03:31:24 +0000, rawValue: 1010, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 101, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6180, date: 2024-08-25 03:26:24 +0000, rawValue: 1010, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 101, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6175, date: 2024-08-25 03:21:24 +0000, rawValue: 1010, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 101, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6170, date: 2024-08-25 03:16:25 +0000, rawValue: 1000, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 100, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6165, date: 2024-08-25 03:11:25 +0000, rawValue: 1000, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 100, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6160, date: 2024-08-25 03:06:25 +0000, rawValue: 1010, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 101, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6155, date: 2024-08-25 03:01:25 +0000, rawValue: 1010, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 101, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6150, date: 2024-08-25 02:56:25 +0000, rawValue: 1010, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 101, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6145, date: 2024-08-25 02:51:25 +0000, rawValue: 1020, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 102, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6140, date: 2024-08-25 02:46:24 +0000, rawValue: 1030, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 103, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6135, date: 2024-08-25 02:41:25 +0000, rawValue: 1040, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 104, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6130, date: 2024-08-25 02:36:24 +0000, rawValue: 1030, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 103, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6125, date: 2024-08-25 02:31:23 +0000, rawValue: 1030, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 103, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6120, date: 2024-08-25 02:26:23 +0000, rawValue: 1030, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 103, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6115, date: 2024-08-25 02:21:25 +0000, rawValue: 1040, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 104, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6110, date: 2024-08-25 02:16:24 +0000, rawValue: 1040, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 104, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6105, date: 2024-08-25 02:11:24 +0000, rawValue: 1050, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 105, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6100, date: 2024-08-25 02:06:24 +0000, rawValue: 1050, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 105, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6095, date: 2024-08-25 02:01:25 +0000, rawValue: 1050, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 105, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6090, date: 2024-08-25 01:56:25 +0000, rawValue: 1060, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 106, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6085, date: 2024-08-25 01:51:24 +0000, rawValue: 1050, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 105, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6080, date: 2024-08-25 01:46:25 +0000, rawValue: 1050, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 105, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6075, date: 2024-08-25 01:41:24 +0000, rawValue: 1060, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 106, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6070, date: 2024-08-25 01:36:25 +0000, rawValue: 1130, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 113, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6065, date: 2024-08-25 01:31:39 +0000, rawValue: 1140, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 114, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6060, date: 2024-08-25 01:26:25 +0000, rawValue: 1130, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 113, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6055, date: 2024-08-25 01:21:24 +0000, rawValue: 1150, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 115, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6050, date: 2024-08-25 01:16:24 +0000, rawValue: 1140, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 114, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6045, date: 2024-08-25 01:11:24 +0000, rawValue: 1130, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 113, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6040, date: 2024-08-25 01:06:24 +0000, rawValue: 1130, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 113, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6035, date: 2024-08-25 01:01:23 +0000, rawValue: 1130, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 113, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6030, date: 2024-08-25 00:56:25 +0000, rawValue: 1120, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 112, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6025, date: 2024-08-25 00:51:25 +0000, rawValue: 1130, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 113, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6020, date: 2024-08-25 00:46:23 +0000, rawValue: 1120, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 112, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6015, date: 2024-08-25 00:41:24 +0000, rawValue: 1110, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 111, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6010, date: 2024-08-25 00:36:23 +0000, rawValue: 1120, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 112, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6005, date: 2024-08-25 00:31:25 +0000, rawValue: 1130, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 113, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 6000, date: 2024-08-25 00:26:24 +0000, rawValue: 1130, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 113, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 5995, date: 2024-08-25 00:21:24 +0000, rawValue: 1130, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 113, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 5990, date: 2024-08-25 00:16:23 +0000, rawValue: 1140, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 114, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 5985, date: 2024-08-25 00:11:23 +0000, rawValue: 1130, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 113, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 5980, date: 2024-08-25 00:06:25 +0000, rawValue: 1120, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 112, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 5975, date: 2024-08-25 00:01:24 +0000, rawValue: 1110, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 111, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 5970, date: 2024-08-24 23:56:24 +0000, rawValue: 1120, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 112, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 5965, date: 2024-08-24 23:51:23 +0000, rawValue: 1110, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 111, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 5960, date: 2024-08-24 23:46:25 +0000, rawValue: 1110, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 111, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 5955, date: 2024-08-24 23:41:24 +0000, rawValue: 1100, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 110, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 5950, date: 2024-08-24 23:36:24 +0000, rawValue: 1100, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 110, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 5945, date: 2024-08-24 23:31:25 +0000, rawValue: 1090, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 109, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 5940, date: 2024-08-24 23:26:24 +0000, rawValue: 1080, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 108, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 5935, date: 2024-08-24 23:21:24 +0000, rawValue: 1080, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 108, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 5930, date: 2024-08-24 23:16:24 +0000, rawValue: 1070, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 107, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 5925, date: 2024-08-24 23:11:25 +0000, rawValue: 1060, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 106, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 5920, date: 2024-08-24 23:06:25 +0000, rawValue: 1050, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 105, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil), LibreWrist.LibreLinkUpGlucose(glucose: LibreWrist.Glucose(id: 5915, date: 2024-08-24 23:01:24 +0000, rawValue: 1050, rawTemperature: 0, temperatureAdjustment: 0, hasError: false, dataQuality: 0x00: OK, dataQualityFlags: 0, value: 105, temperature: 0.0, trendRate: 0.0, trendArrow: 0, source: "LibreLinkUp"), color: LibreWrist.MeasurementColor.green, trendArrow: nil)]
    
}
