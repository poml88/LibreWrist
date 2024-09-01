//
//  PhoneAppSettingsView.swift
//  LibreWrist
//
//  Created by Peter Müller on 01.09.24.
//

import SwiftUI

struct PhoneAppSettingsView: View {
    
    @AppStorage(SharedData.Keys.insulinSelected.key, store: SharedData.defaultsGroup) private var insulinSelected: Double = 0.0
    
    @StateObject var watchConnector = PhoneToWatchConnector()
    
    @State private var pickerTimeStamp: Date = Date.now
    @State private var insulinDeliveryHistory: [InsulinDelivery] = UserDefaults.group.insulinDeliveryHistory ?? []
    @State private var isShowingInsulinDelivery = false
    
//    @Binding var selectedTab: String
    
    let insulinDoses: [Double] = Array(stride(from: 0.5, to: 60, by: 0.5))
    
    var body: some View {
        Form {
            Section {
                Picker("Insulin units", selection: $insulinSelected) {
                    ForEach(insulinDoses, id: \.self) {
                        Text("\($0, specifier: "%.1f")")
                    }
                }
                .pickerStyle(.menu)
                DatePicker("Please enter a date", selection: $pickerTimeStamp)
                
                    .labelsHidden()

                
                Button {
                    if insulinSelected > 0 {
                        let insulinDeliveryTimeStamp = pickerTimeStamp.timeIntervalSince1970
                        pickerTimeStamp = Date.now
                        let insulinDeliveryUnits = insulinSelected
                        let insulinDeliveryHistoryItem = InsulinDelivery(id: UUID(), timestamp: insulinDeliveryTimeStamp, insulinUnits: insulinDeliveryUnits)
                        insulinDeliveryHistory.append(insulinDeliveryHistoryItem)
                        UserDefaults.group.insulinDeliveryHistory = insulinDeliveryHistory
                        isShowingInsulinDelivery = true
                        
                        let messageToWatch: [String: Any] = ["content": "insulinDelivery",
                                                             "timeStamp": insulinDeliveryTimeStamp,
                                                             "units": insulinDeliveryUnits]
                        sendMessagetoWatch(message: messageToWatch)
//                        selectedTab = "Home"
                    }
                } label:                    {
                    Text("Add insulin")
                }
                .buttonStyle(.borderedProminent)
                
                Button {
                    
                    insulinDeliveryHistory = []
                    UserDefaults.group.insulinDeliveryHistory = insulinDeliveryHistory
                    
                } label:                    {
                    Text("Reset IOB")
                }
                .buttonStyle(.borderedProminent)
                
            } header: {
                Text("Bolus Insulin (Novorapid)")
            }
        }
        .navigationBarTitle("Settings")
        .alert ("Success", isPresented: $isShowingInsulinDelivery) {
//            Button("Accept", role: .cancel, action: {settings.hasSeenDisclaimer = true})
        }
    message: {
            Text("Saved \(insulinSelected, specifier: "%.1f") units.")
        }
    }
    
    func sendMessagetoWatch(message: [String: Any]){
        
        //            let messageToSend: [String: Any] = ["message": message]
        watchConnector.sendMessagetoWatch(message)
    }
    
}

#Preview {
    PhoneAppSettingsView()
}
