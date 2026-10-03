//
//  QR_ScannerApp.swift
//  QR Scanner
//
//  Created by Brent Amersbach on 2/14/25.
//

import SwiftUI
import CodeScanner

@main
struct QR_ScannerApp: App {
    #if DEBUG
    @StateObject var globalData = GlobalData(createDemoHistory: true)
    #else
    @StateObject var globalData = GlobalData()
    #endif

    var body: some Scene {
        WindowGroup {
            if !globalData.scanHistory.isEmpty {
                MainView(currentScan: globalData.scanHistory[globalData.currentScanIndex ?? 0])
                    .environmentObject(globalData)
            } else {
                MainView()
                    .environmentObject(globalData)
            }
        }
    }
}
