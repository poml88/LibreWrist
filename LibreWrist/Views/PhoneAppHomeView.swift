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
    @State private var isReloading: Bool = false
    @State private var isShowingDisclaimer = false
    
    @State var lastReadingDate: Date = Date.distantPast
    @State var sensor: Sensor!
    @State var currentGlucose: Int = 0
    @State var trendArrow = "---"
    
    
    var body: some View {
        VStack {
            HStack {
                Text("\(currentGlucose)")
                    .font(.system(size: 128)) //, weight: .bold)
                    .minimumScaleFactor(0.1)
                    .padding()
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
                    }
                }
                .padding()
            }
            .frame(maxWidth: .infinity)
            .safeAreaPadding(0)
            .background(Color(libreLinkUpHistory[0].color.color))
            
            
            if libreLinkUpHistory.count > 0 {
                let rectXStart: Date = libreLinkUpHistory.last?.glucose.date ?? Date.distantPast
                let rectXStop: Date = libreLinkUpHistory.first?.glucose.date ?? Date.distantFuture
                
                //Configuration
                let chartYScaleMin = 50
                let chartYScaleMax = 250
                // Setting to 6 hours below by deleting half of the values.
                
                Chart {
                    //                    RuleMark(y: .value("Minimum High", 300))
                    //                        .foregroundStyle(.clear)
                    
                    RectangleMark(
                        xStart: .value("Rect Start Width", rectXStart),
                        xEnd: .value("Rect End Width", rectXStop),
                        yStart: .value("Rect Start Height", 70),
                        yEnd: .value("Rect End Height", 180)
                    )
                    .opacity(0.2)
                    .foregroundStyle(.green)
                    
                    RuleMark(y: .value("Lower limit", 85))
                        .foregroundStyle(.red)
                        .lineStyle(.init(lineWidth: 1, dash: [2]))
                    
//                    RuleMark(y: .value("Upper limit", 300))
//                        .foregroundStyle(.red)
//                        .lineStyle(.init(lineWidth: 1, dash: [2]))

//                    switch libreLinkUpHistory[0].color {
//                    case .green:
//                            .foregroundStyle(.green)
//                    case .yellow:
//                            .foregroundStyle(.yellow)
//                    case .orange:
//                            .foregroundStyle(.orange)
//                    case red:
//                            .foregroundStyle(.red)
//                    default:
//                            .foregroundStyle(.white)
//                    }

                    ForEach(libreLinkUpHistory) { item in
                                                
//                        PointMark(x: .value("Time", item.glucose.date),
//                                  y: .value("Glucose", item.glucose.value)
//                        )
//                        .foregroundStyle(item.color.color)
//                        .symbolSize(12)
                        
                        LineMark(x: .value("Time", item.glucose.date),
                                 y: .value("Glucose", item.glucose.value))
                        .interpolationMethod(.linear)
                        .lineStyle(.init(lineWidth: 5))
                        .symbol(){
                            Circle()
                                .fill(item.color.color)
                                .frame(width: 6, height: 6)
                        }
//                        .symbolSize(100)
                        
                        
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
                    
                    #warning ("breaks preview")
                    ForEach(history.factoryTrend) { item in
                        PointMark(x: .value("Time", item.date),
                                  y: .value("Glucose", item.value)
                        )
                        .foregroundStyle(Color.yellow)
                        .symbolSize(20)
                        
                    }
                }
                .chartYScale(domain: [chartYScaleMin, chartYScaleMax])
//                .chartXVisibleDomain(length: 3600 * 6)
//                .chartScrollableAxes(.horizontal)
//                .chartScrollPosition(initialX: Date())
                .chartXAxis {
                    AxisMarks(values: .stride(by: .hour, count: 2)) { _ in
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
        .alert ("Warning", isPresented: $isShowingDisclaimer) {
            Button("Accept", role: .cancel, action: {settings.hasSeenDisclaimer = true})
        }
    message: {
            Text("!! Not for treatment decisions !!\n\nUse at your own risk!\n\nThe information presented in this app and its extensions must not be used for treatment or dosing decisions. Consult the glucose-monitoring system and/or a healthcare professional.")
        }
        
        
        .overlay
        {
            if isReloading == true {
                ZStack {
                    Color(white: 0, opacity: 0.25)
                    ProgressView().tint(.white)
                }
            }
        }
        .onReceive(timer) { time in
            print("Timer")
            minutesSinceLastReading = Int(Date().timeIntervalSince(lastReadingDate) / 60)
            if minutesSinceLastReading >= 1 {
                Task {
                    isReloading = true
                    await reloadLibreLinkUp()
                    isReloading = false
                }
            }
        }
        .onAppear() { // fires when switching the Views, e.g. form settings to home view.
            print("onAppear")
            if settings.hasSeenDisclaimer == false {
                isShowingDisclaimer = true
            }
            minutesSinceLastReading = Int(Date().timeIntervalSince(lastReadingDate) / 60)
//            if minutesSinceLastReading >= 1 {
//                Task {
//                    isReloading = true
//                    await reloadLibreLinkUp()
//                    isReloading = false
//                }
//            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                print("Active")
                minutesSinceLastReading = Int(Date().timeIntervalSince(lastReadingDate) / 60)
                if minutesSinceLastReading >= 1 {
                    Task {
                        isReloading = true
                        await reloadLibreLinkUp()
                        isReloading = false
                    }
                }
            } else if newPhase == .inactive {
                print("Inactive")
            } else if newPhase == .background {
                print("Background")
            }
        }
        .overlay {
            if minutesSinceLastReading >= 3 && isReloading == false {
                ZStack {
                    Color(white: 0, opacity: 0.5)
                    
                    VStack {
                        Image(systemName: "hourglass.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100)
                            .padding()
                        
                        Text("No data received since \(minutesSinceLastReading) min.\n\nCheck network and bluetooth connections.")
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .background()
                    .cornerRadius(10)
                    .opacity(0.5)
                }
                .ignoresSafeArea()
            }
        }
    }
    
    
    func reloadLibreLinkUp() async {
        
        var dataString = ""
        var retries = 0
        let dropLastValues = 70
        
        
    loop: repeat {
        do {
            let token = settings.libreLinkUpToken
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
                libreLinkUpHistory = graphHistory.reversed().dropLast(dropLastValues)
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
                        // keep only the latest 16 minutes considering the 17-minute latency of the historic values update
                        trend = trend.filter { lastMeasurement.id - $0.id < 16 }
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

