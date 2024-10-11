//
//  LibreWristWidget.swift
//  LibreWristWidget
//
//  Created by Peter Müller on 02.10.24.
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
        case .systemSmall:
            ZStack {
                entry.glucoseMeasurement.measurementColor.color
                VStack(alignment: .center, spacing: -10) {
                    HStack {
                        Text(verbatim: entry.glucoseMeasurement.trendArrow?.symbol ?? "-")
                            .font(.system(size: 48, weight: .heavy, design: .monospaced))
                            .foregroundColor(.black)
                            .padding(.leading, 60)
                            .padding(.trailing, 5)
                        Button(intent: ReloadWidgetIntent()) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 20, weight: .heavy, design: .monospaced))
                                .foregroundColor(.black)
                        }
                    }
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
            ZStack {
//                if #available(iOSApplicationExtension 17.0, *) {
//                    // TODO
//                } else {
//                    Color(.white)
//                }
                AccessoryWidgetBackground()
                VStack(alignment: .center, spacing: -6) {
                    Button(intent: ReloadWidgetIntent()) {
                        Text(verbatim: entry.glucoseMeasurement.trendArrow?.symbol ?? "-")
                            .font(.system(size: 20, weight: .heavy, design: .monospaced))
                        //.colorInvert()
                        //.widgetAccentable()
                    }
                    .buttonStyle(PlainButtonStyle())
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
        case .accessoryRectangular:
            ZStack {
//                if #available(iOSApplicationExtension 17.0, *) {
//                    // TODO
//                } else {
//                    Color(.white)
//                }
                AccessoryWidgetBackground()
                HStack {
                    VStack (alignment: .center, spacing: 6){
                        Text("\(entry.currentIOB, specifier: "%.2f")u")
                            .font(.system(size: 15, weight: .heavy))
                        
                        Text(Date(), style: .timer)
                        //Text(verbatim: " ")
                            .font(.system(size: 12, weight: .heavy))
                        //.colorInvert()
                            .multilineTextAlignment(.center)
                            .monospacedDigit()
//                            .padding(4)
                    }
                    VStack(alignment: .center, spacing: -6)
                    {
                        Text(verbatim: entry.glucoseMeasurement.trendArrow?.symbol ?? "-")
                            .font(.system(size: 25, weight: .heavy, design: .monospaced))
                        //.colorInvert()
                        //.widgetAccentable()
                        
                        Text(verbatim: glucose)
                            .font(.system(size: 25, weight: .heavy))
                        //.colorInvert()
                    }
                    Button(intent: ReloadWidgetIntent()) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 20, weight: .heavy))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.trailing,5)
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
//                Color.clear
                background()
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
        .supportedFamilies([.accessoryCircular, .systemSmall, .accessoryRectangular])
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

#Preview("accessRect", as: .accessoryRectangular) {
    LibreWristWidget()
} timeline: {
//    SimpleEntry(date: .now, emoji: "😀")
//    SimpleEntry(date: .now, emoji: "🤩")
    GlucoseMeasurementEntry.sampleEntry
}
