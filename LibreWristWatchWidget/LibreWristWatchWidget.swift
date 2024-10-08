//
//  LibreWristWatchWidget.swift
//  LibreWristWatchWidget
//
//  Created by Peter Müller on 08.10.24.
//

import WidgetKit
import SwiftUI


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

        case .accessoryCircular:
//            ZStack(alignment: .center) {
//                if #available(iOSApplicationExtension 17.0, *) {
//                    // TODO
//                } else {
//                    Color(.white)
//                }
//             AccessoryWidgetBackground()
             VStack(alignment: .center, spacing: -6) {
                    Text(verbatim: entry.glucoseMeasurement.trendArrow?.symbol ?? "-")
                            .font(.system(size: 20, weight: .heavy, design: .monospaced))
                            .foregroundColor(entry.glucoseMeasurement.measurementColor.color)
                            //.colorInvert()
                            .widgetAccentable()
                    Text(verbatim: glucose)
                            .font(.system(size: 20, weight: .heavy))
                            .foregroundColor(entry.glucoseMeasurement.measurementColor.color)
                            //.colorInvert()
                            .widgetAccentable()
                    Text(Date(), style: .timer)
                    //Text(verbatim: " ")
                            .font(.system(size: 10, weight: .heavy))
                            //.colorInvert()
                            .multilineTextAlignment(.center)
                            .monospacedDigit()
                            .padding(4)
                            
                            
                }
//            }
//            .containerBackground(for: .widget) {
//                background()
//            }
             .containerBackground(.background, for: .widget)
        default:
            VStack(alignment: .center) {
                Text("default")
            }
            .containerBackground(.background, for: .widget)
        }
    }
}

@main
struct LibreWristWatchWidget: Widget {
    let kind: String = "LibreWristWatchWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: Provider()
        ) { entry in
            LibreWristWidgetEntryView(entry: entry)
        }
        .supportedFamilies([.accessoryCircular])
        .configurationDisplayName("Glucose Widget")
        .description("This widget displays the latest blood glucose value.")
//        .contentMarginsDisabled()
    }

   
}

#Preview("accessCirc", as: .accessoryCircular) {
    LibreWristWatchWidget()
} timeline: {
    GlucoseMeasurementEntry.sampleEntry
}
