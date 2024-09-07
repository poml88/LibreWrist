//
//  WatchAppSettingsView.swift
//  LibreWristWatch Watch App
//
//  Created by Peter Müller on 26.08.24.
//
/*
import SwiftUI
import SecureDefaults

struct WatchAppSettingsView: View {
    
    @State private var username = UserDefaults.group.username
    @State private var password = SecureDefaults.sgroup.string(forKey: "llu.password") ?? ""
    @State private var libreLinkUpResponse: String = "[...]"
    @State private var connected = UserDefaults.group.connected
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            
            Text(statusMessage())
//                .padding(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
                .padding()
                .font(.headline)
                .background(statusColor())
                .cornerRadius(5)
                .safeAreaPadding(0)
               
                
                
            Form {
                TextField("email", text: $username)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .textContentType(.emailAddress)
                    .onChange(of: username) { _ in
                        UserDefaults.group.connected = .disconnected
                        settings.libreLinkUpToken = ""
                    }
                SecureField("password", text: $password)
                    .onChange(of: password) { _ in
                        UserDefaults.group.connected = .disconnected
                        settings.libreLinkUpToken = ""
                    }
                Button("Connect" ) {
                    tryToConnect()
                }
                .disabled(username.isBlank || password.isBlank)
            }
            .disabled(connected == .connecting || connected == .locked)
        }
        .padding(.top, -20)
        .overlay
        {
            if connected == .connecting {
                ZStack {
                    Color(white: 0, opacity: 0.5)
                    ProgressView().tint(.white)
                }
            }
        }
        .onReceive(timer) { time in
            // TODO: synchronize by common method
            connected = UserDefaults.group.connected
            //    UserDefaults.group.connected.connected = .disconnected
        }
    }
    
    
    private func tryToConnect() {
        settings.libreLinkUpToken = ""
        UserDefaults.group.username = username
        let sdefaults = SecureDefaults.sgroup
        if !sdefaults.isKeyCreated {
            sdefaults.password = UUID().uuidString
        }
        sdefaults.set(password, forKey: "llu.password")
        sdefaults.synchronize()
        //        appConfiguration.password = password
        UserDefaults.group.connected = .connecting
//        let libreLinkUpConection = LibreLinkUpConnection()
//        libreLinkUpConection.connectConnection ()
        Task {
            do {
                try await LibreLinkUp().login()
                UserDefaults.group.connected = .connected
            } catch {
                libreLinkUpResponse = error.localizedDescription.capitalized
                UserDefaults.group.connected = .disconnected
            }
        }
    }
    
    
    func statusMessage() -> String {
        switch connected {
        case .connected: return "Connected."
        case .connecting: return "Connecting..."
        case .disconnected: return "Disconnected"
        case .failed: return "Connection failed."
        case .locked: return "Access temporarly locked."
        }
    }
    
    
    func statusColor() -> Color {
        switch connected {
        case .connected: return .green
        case .connecting: return .orange
        case .disconnected: return .gray
        case .failed: return .red
        case .locked: return .black
        }
    }
}


#Preview {
    WatchAppSettingsView()
}
*/
