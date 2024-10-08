//
//  LibreWristWidget.swift
//  LibreWristWidget
//
//  Created by Peter Müller on 02.10.24.
//

import WidgetKit
import SwiftUI


struct GlucoseMeasurementEntry: TimelineEntry {
    let date: Date
    let glucoseMeasurement: GlucoseMeasurement
    
    static let sampleEntry = GlucoseMeasurementEntry(date: Date(), glucoseMeasurement: GlucoseMeasurement(factoryTimestamp: "", timestamp: "", type: 0, alarmType: 3, valueInMgPerDl: 105, trendArrow: .stable, trendMessage: "", measurementColor: .green, glucoseUnits: 1, value: 105, isHigh: false, isLow: false))
    
    static let invalidEntry = GlucoseMeasurementEntry(date: Date(), glucoseMeasurement: GlucoseMeasurement(factoryTimestamp: "", timestamp: "", type: 0, alarmType: 3, valueInMgPerDl: 0, trendArrow: .unknown, trendMessage: "", measurementColor: .gray, glucoseUnits: 1, value: 0, isHigh: false, isLow: false))
    
    static func getLastGlucoseMeasurement(completion: @escaping (GlucoseMeasurementEntry?, Any?) -> ()) {
        if !(settings.libreLinkUpUserId.isEmpty ||
             settings.libreLinkUpToken.isEmpty) {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "M/d/yyyy h:mm:ss a"
            
            var request = URLRequest(url: URL(string: "https://api-\(settings.libreLinkUpRegion).libreview.io/llu/connections")!)
            request.timeoutInterval = 15
            request.httpMethod = "GET"
            print("\(request)")
            let headers = LLUHeaders().headers
            var authenticatedHeaders = headers
            authenticatedHeaders["Authorization"] = "Bearer \(settings.libreLinkUpToken)"
            authenticatedHeaders["Account-Id"] = settings.libreLinkUpUserId.SHA256
            for (header, value) in authenticatedHeaders {
                request.setValue(value, forHTTPHeaderField: header)
            }
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let data = data {
                    do {
                        
                        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let data = json["data"] as? [[String: Any]] {
                            if data.count > 0 {
                                let connection = data[0]
                                if let lastGlucoseMeasurement = connection["glucoseMeasurement"] as? [String: Any],
                                   let measurementData = try? JSONSerialization.data(withJSONObject: lastGlucoseMeasurement),
                                   let measurement = try? JSONDecoder().decode(GlucoseMeasurement.self, from: measurementData) {
                                    let date = dateFormatter.date(from: measurement.timestamp)!
                                    let glucoseMeasurementEntry = GlucoseMeasurementEntry(date: date, glucoseMeasurement: measurement)
                                    let lifeCount = 0 // Int(round(date.timeIntervalSince(activationDate) / 60))
//                                    let lastGlucose = LibreLinkUpGlucose(glucose: Glucose(measurement.valueInMgPerDl, id: lifeCount, date: date, source: "LibreLinkUp"), color: measurement.measurementColor, trendArrow: measurement.trendArrow)
//                                    
//                                    let measurementString = "\(measurement)"
                                    completion(glucoseMeasurementEntry, nil)
                                }
                            }
                        } else {
                            completion(nil, "No glucose item found in response.")
                        }
                    } catch {
                        completion(nil, error)
                    }
                } else if let error = error {
                    completion(nil, error)
                }
            }
            .resume()
        }
    }
}





struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> GlucoseMeasurementEntry {
        return GlucoseMeasurementEntry.sampleEntry
    }
    
    func getSnapshot(in context: Context, completion: @escaping (GlucoseMeasurementEntry) -> ()) {
        let entry = GlucoseMeasurementEntry.sampleEntry
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [GlucoseMeasurementEntry] = []
        
        
        GlucoseMeasurementEntry.getLastGlucoseMeasurement { glucoseMeasurementEntry, error in
            if let gme = glucoseMeasurementEntry {
                guard Int(Date().timeIntervalSince(glucoseMeasurementEntry?.date ?? Date.distantPast) / 60) <= 3 else {
                    let entry = GlucoseMeasurementEntry.invalidEntry
                    entries.append(entry)
                    
                    let reloadDate = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
                    let timeline = Timeline(entries: entries, policy: .after(reloadDate))
                    return completion(timeline)
                    
                }
                let entry = gme
                entries.append(entry)
                
                let reloadDate = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
                let timeline = Timeline(entries: entries, policy: .after(reloadDate))
                completion(timeline)
            } else {
                let entry = GlucoseMeasurementEntry.invalidEntry
                entries.append(entry)
                
                let reloadDate = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
                let timeline = Timeline(entries: entries, policy: .after(reloadDate))
                completion(timeline)
            }
        }
    }
}




struct LibreWristWidgetEntryView : View {
    var entry: Provider.Entry

    @Environment(\.widgetFamily) private var family
    
    var glucose: String {
        if entry.glucoseMeasurement.value <= 0 {
            return "--"
        } else if entry.glucoseMeasurement.glucoseUnits == 1 {
            return "\(Int(entry.glucoseMeasurement.value))"
        } else {
            return String(format: "%.1f", entry.glucoseMeasurement.value)
        }
    }
    
    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            ZStack {
                entry.glucoseMeasurement.measurementColor.color
                VStack(alignment: .center, spacing: -10) {
                    Text(verbatim: entry.glucoseMeasurement.trendArrow?.symbol ?? "-")
                            .font(.system(size: 48, weight: .heavy, design: .monospaced))
                            .foregroundColor(.black)
                    Text(verbatim: glucose)
                            .font(.system(size: 52, weight: .heavy))
                            .foregroundColor(.black)
                    Text(Date(), style: .offset)
                    //Text(verbatim: " ")
                            .font(.system(size: 20, weight: .heavy))
                            .foregroundColor(.black)
                            //.colorInvert()
                            .multilineTextAlignment(.center)
                            .monospacedDigit()
                            .padding(4)
                            //.frame(width: 10)
                }
            }
            .containerBackground(for: .widget) {
                Color.clear
            }
        case .accessoryCircular:
            ZStack(alignment: .center) {
                if #available(iOSApplicationExtension 17.0, *) {
                    // TODO
                } else {
                    Color(.white)
                }
             AccessoryWidgetBackground()
             VStack(alignment: .center, spacing: -6) {
                    Text(verbatim: entry.glucoseMeasurement.trendArrow?.symbol ?? "-")
                            .font(.system(size: 20, weight: .heavy, design: .monospaced))
                            //.colorInvert()
                            //.widgetAccentable()
                    Text(verbatim: glucose)
                            .font(.system(size: 20, weight: .heavy))
                            //.colorInvert()
                    Text(Date(), style: .timer)
                    //Text(verbatim: " ")
                            .font(.system(size: 10, weight: .heavy))
                            //.colorInvert()
                            .multilineTextAlignment(.center)
                            .monospacedDigit()
                            .padding(4)
                }
            }
            .containerBackground(for: .widget) {
                EmptyView()
            }
        default:
            VStack(alignment: .center) {
                Text("default")
            }
            .containerBackground(for: .widget) {
                Color.clear
            }
        }
    }
}

struct LibreWristWidget: Widget {
    let kind: String = "LibreWristWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: Provider()
        ) { entry in
            LibreWristWidgetEntryView(entry: entry)
        }
        .supportedFamilies([.accessoryCircular, .systemSmall])
        .configurationDisplayName("Glucose Widget")
        .description("This widget displays the latest blood glucose value.")
        .contentMarginsDisabled()
    }
}
    

    
 

#Preview("systSma", as: .systemSmall) {
    LibreWristWidget()
} timeline: {
//    SimpleEntry(date: .now, emoji: "😀")
//    SimpleEntry(date: .now, emoji: "🤩")
    GlucoseMeasurementEntry.sampleEntry
}

#Preview("accessCirc", as: .accessoryCircular) {
    LibreWristWidget()
} timeline: {
//    SimpleEntry(date: .now, emoji: "😀")
//    SimpleEntry(date: .now, emoji: "🤩")
    GlucoseMeasurementEntry.sampleEntry
}
