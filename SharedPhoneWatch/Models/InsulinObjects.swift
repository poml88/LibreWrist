//
//  InsulinObjects.swift
//  LibreWrist
//
//  Created by Peter Müller on 01.09.24.
//

import Foundation

struct InsulinDelivery: Codable, Identifiable {
    let id: UUID
    let timeStamp: Double
    let insulinUnits: Double
    
    init(id: UUID, timestamp: Double, insulinUnits: Double) {
        self.id = UUID()
        self.timeStamp = timestamp
        self.insulinUnits = insulinUnits
    }
}

struct InsulinType: Codable, Identifiable {
    let id: UUID
    let actionDuration: Int
    let peakActivityTime: Int
    let delay: Int
    
    init(id: UUID, actionDuration: Int, peakActivityTime: Int, delay: Int) {
        self.id = UUID()
        self.actionDuration = actionDuration
        self.peakActivityTime = peakActivityTime
        self.delay = delay
    }
}
