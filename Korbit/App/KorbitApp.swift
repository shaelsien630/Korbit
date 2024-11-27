//
//  KorbitApp.swift
//  Korbit
//
//  Created by 최서희 on 11/13/24.
//

import SwiftUI

@main
struct korbitApp: App {
    @StateObject private var tickerVM = ViewModel()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(tickerVM)
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                if !tickerVM.isWebSocketConnected { tickerVM.reconnectWebSocket() }
            case .background:
                tickerVM.disconnectWebSocket()
            @unknown default:
                break
            }
        }
    }
}


