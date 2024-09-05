//
//  PhoneAppSettingsView.swift
//  LibreWrist
//
//  Created by Peter Müller on 01.09.24.
//

import SwiftUI

struct PhoneAppInsulinDeliveryView: View {
    
    @AppStorage(SharedData.Keys.insulinSelected.key, store: SharedData.defaultsGroup) private var insulinSelected: Double = 0.0
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject var watchConnector = PhoneToWatchConnector()
    
    @State private var pickerTimeStamp: Date = Date.now
    @State private var insulinDeliveryHistory: [InsulinDelivery] = UserDefaults.group.insulinDeliveryHistory ?? []
    @State private var isShowingInsulinDeliverySubmitAlert = false
    @State private var isShowingInsulinDeliveryResetAlert = false
    
    //    @Binding var selectedTab: String
    
    let insulinDoses: [Double] = Array(stride(from: 0.5, to: 60, by: 0.5))
    
    var body: some View {
        VStack{
            
            
            Button {
                dismiss()
            } label: {
                Text("Dismiss")
            }
            .buttonStyle(.borderedProminent)
            .padding()
            
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
                        isShowingInsulinDeliverySubmitAlert = true
                    } label: {
                        Text("Add insulin")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(insulinSelected == 0.0)
                    
                    Button {
                        isShowingInsulinDeliveryResetAlert.toggle()
                    } label:                    {
                        Text("Reset IOB")
                    }
                    .buttonStyle(.borderedProminent)
                } header: {
                    Text("Bolus Insulin (Novorapid)")
                }
            }
            //        .navigationBarTitle("Settings")
            .alert ("Confirm", isPresented: $isShowingInsulinDeliverySubmitAlert) {
                Button("Submit", action: {
                    let insulinDeliveryTimeStamp = pickerTimeStamp.timeIntervalSince1970
                    let insulinDeliveryUnits = insulinSelected
                    let insulinDeliveryHistoryItem = InsulinDelivery(id: UUID(), timestamp: insulinDeliveryTimeStamp, insulinUnits: insulinDeliveryUnits)
                    insulinDeliveryHistory.append(insulinDeliveryHistoryItem)
                    UserDefaults.group.insulinDeliveryHistory = insulinDeliveryHistory
                    
                    let messageToWatch: [String: Any] = ["content": "insulinDelivery",
                                                         "timeStamp": insulinDeliveryTimeStamp,
                                                         "units": insulinDeliveryUnits]
                    sendMessagetoWatch(message: messageToWatch)
                    dismiss()
                    //                        selectedTab = "Home"
                })
                Button("Cancel", role: .cancel, action: {})
            } message: {
                
                Text("Do you want to add \(insulinSelected, specifier: "%.1f") units?")
            }
            
            .alert ("Confirm", isPresented: $isShowingInsulinDeliveryResetAlert) {
                Button("Reset", action: {
                    pickerTimeStamp = Date.now
                    insulinDeliveryHistory = []
                    UserDefaults.group.insulinDeliveryHistory = insulinDeliveryHistory
                    let messageToWatch: [String: Any] = ["content": "clearInsulinHistory"]
                    sendMessagetoWatch(message: messageToWatch)
                })
                Button("Cancel", role: .cancel, action: {})
            } message: {
                Text("Do you want to reset insulin history?")
            }
            List{
                ForEach(insulinDeliveryHistory, id: \.id) {item in
                    Text("Time: \(Date(timeIntervalSince1970: item.timeStamp).toLocalTime())       Units: \(item.insulinUnits, specifier: "%.1f")")
                }
                
            }
            
                    }
    }
    
    func sendMessagetoWatch(message: [String: Any]) {
        watchConnector.sendMessagetoWatch(message)
    }
}

#Preview {
    PhoneAppInsulinDeliveryView()
}
