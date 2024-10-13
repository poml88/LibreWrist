//
//  InsulinObjects.swift
//  LibreWrist
//
//  Created by Peter Müller on 01.09.24.
//

import SwiftUI

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
    let actionDuration: Double
    let peakActivityTime: Double
    let delay: Double
    
    init(id: UUID, actionDuration: Double, peakActivityTime: Double, delay: Double) {
        self.id = UUID()
        self.actionDuration = actionDuration
        self.peakActivityTime = peakActivityTime
        self.delay = delay
    }
    static let novorapid = InsulinType(id: UUID(), actionDuration: 270 * 60, peakActivityTime: 120 * 60, delay: 15 * 60)

}


@Observable class CurrentIOBSingleton {
    
    var currentIOB: Double = 0.0
    
    static let shared: CurrentIOBSingleton = {
        let instance = CurrentIOBSingleton()
        return instance
    }()
    
    private init() {}
    
    func getCurrentIOB() -> Double {
        var insulinDeliveryHistory: [InsulinDelivery] = UserDefaults.group.insulinDeliveryHistory ?? []
        var sumIOB: Double = 0
        for item in insulinDeliveryHistory {
            if Date().timeIntervalSince1970 - item.timeStamp > 12 * 60 * 60 {
                insulinDeliveryHistory.removeAll(where: {$0.id == item.id})
            } else {
                let IOB =   updateIOB(timeStamp: item.timeStamp) * item.insulinUnits
                sumIOB = sumIOB + IOB
            }
        }
        
        UserDefaults.group.insulinDeliveryHistory = insulinDeliveryHistory
        let currentIOB: Double = sumIOB
        return currentIOB
    }
    
    private func updateIOB(timeStamp time: Double) -> Double {
        let model = ExponentialInsulinModel(actionDuration: InsulinType.novorapid.actionDuration, peakActivityTime: InsulinType.novorapid.peakActivityTime, delay: InsulinType.novorapid.delay)
        let result = model.percentEffectRemaining(at: Date().timeIntervalSince1970 - time)
        return result
    }

}





extension EnvironmentValues {
    var currentIOBSingleton: CurrentIOBSingleton {
        get { self[CurrentIOBSingletonKey.self] }
        set { self[CurrentIOBSingletonKey.self] = newValue }
    }
}


private struct CurrentIOBSingletonKey: EnvironmentKey {
    static var defaultValue: CurrentIOBSingleton = CurrentIOBSingleton.shared
}


