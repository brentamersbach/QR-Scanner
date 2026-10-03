//
//  QR_ScannerApp.swift
//  QR Scanner
//
//  Created by Brent Amersbach on 2/14/25.
//

import SwiftUI
import CodeScanner
import SwiftData

@main
struct QR_ScannerApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .modelContainer(for: ScanRecord.self)
    }
}
