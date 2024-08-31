//
//  PhoneAppSetupView.swift
//  LibreWrist
//
//  Created by Peter Müller on 29.07.24.
//

import SwiftUI
import OSLog
import SecureDefaults
 

struct PhoneAppSetupView: View {
    
    @State private var username = UserDefaults.group.username
    @State private var password = SecureDefaults.sgroup.string(forKey: "llu.password") ?? ""
    @State private var connected = UserDefaults.group.connected
    @State private var libreLinkUpResponse: String = "[...]"
    

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    
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
    
    
    var body: some View {
        VStack {
            
            Text("LibreWrist")
                .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
                .font(.system(.title))
                .foregroundColor(.green)
            
            
            Form {
                Section(header: Text("Credentials"), footer: Text("Enter the credentials for your [LibreLinkUp follower account](https://www.librelinkup.com/) and press the Connect button.".attributed)) {
                    TextField(text: $username, prompt: Text("Username (email adress)")) {
                        Text("Username")
                    }.textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .onChange(of: username) { _ in
                            UserDefaults.group.connected = .disconnected
                            settings.libreLinkUpToken = ""
                        }
                    SecureField(text: $password, prompt: Text("Password")) {
                        Text("Password")
                    }.onChange(of: password) { _ in
                        UserDefaults.group.connected = .disconnected
                        settings.libreLinkUpToken = ""
                    }
                }
                Section {
                    Button("Connect") {
                        tryToConnect()
                    }
                }
                .disabled(username.isBlank || password.isBlank)
                
                if connected == .connected {
                    Text("**Not for treatment decisions.**\\\n\\\nThe information presented in this app and its extensions must not be used for treatment or dosing decisions. Consult the glucose-monitoring system and/or a healthcare professional.".attributed)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .font(.system(size: 16))
                        .foregroundColor(.red)
                }
            }
            .disabled(connected == .connecting || connected == .locked)
            
            Text(statusMessage())
                .padding(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
                .frame(maxWidth: .infinity)
                .background(statusColor())
                
            Spacer()
        }
        .overlay
        {
            if connected == .connecting {
                ZStack {
                    Color(white: 0, opacity: 0.25)
                    ProgressView().tint(.white)
                }
            }
        }
//        .background(LinearGradient(
//            colors: [.white, .white, statusColor()],
//            startPoint: .top,
//            endPoint: .bottom)
//        )
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
        if !(sdefaults.isKeyCreated) {
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
        
        
        
        
//        libreViewAPI.fetchCurrentGlucoseEntry { glucose, error in
//            if glucose != nil {
//                appConfiguration.connected = .connected
//            } else {
//                if error is Int && error as? Int == FetchStatus.LOCKED {
//                    appConfiguration.connected = .locked
//                } else {
//                    appConfiguration.connected = .failed
//                }
//            }
//        }
        
    }
}

#Preview {
    PhoneAppSetupView()
}
