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
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(tickerVM)
        }
    }
}
