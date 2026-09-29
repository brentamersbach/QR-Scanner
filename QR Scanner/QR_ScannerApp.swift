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
    @StateObject var globalData = GlobalData()
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(globalData)
        }
    }
}
