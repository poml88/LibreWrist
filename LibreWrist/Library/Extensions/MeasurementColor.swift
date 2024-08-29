//
//  MeasurementColor.swift
//  LibreWrist
//
//  Created by Peter Müller on 28.08.24.
//

import SwiftUI


extension MeasurementColor {
    var color: Color {
        switch self {
        case .green:  .green
        case .yellow: .yellow
        case .orange: .orange
        case .red:    .red
        }
    }
}
