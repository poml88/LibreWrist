//
//  LibreLinkUpGlucose.swift
//  LibreWrist
//
//  Created by Peter Müller on 10.09.24.
//

import Foundation

struct LibreLinkUpGlucose: Identifiable, Codable {
    let glucose: Glucose
    let color: MeasurementColor
    let trendArrow: TrendArrow?
    var id: Int { glucose.id }
}
