//
//  History.swift
//  QR Scanner
//
//  Created by Brent Amersbach on 8/10/26.
//

import Foundation
import CodeScanner

class GlobalData: ObservableObject {
    @Published var scanHistory: [ScanRecord]
    @Published var currentScanIndex: Int?
    let maxScanHistory: Int = 20
    var createDemoHistory = false

    init() {
        self.scanHistory = []
    }

    // This is only used for testing or in Xcode Previews
    convenience init(createDemoHistory: Bool) {
        self.init()
        if createDemoHistory {
            self.scanHistory = [
                ScanRecord(resultErrorCorrectionLevel: "M - 15%", resultMaskPattern: "(row + column) mod 2 == 0", resultType: "org.iso.QRCode", resultString: "Sample Data 1", resultSymbolVersion: "2", date: Date()),
                ScanRecord(resultErrorCorrectionLevel: "M - 15%", resultMaskPattern: "(row + column) mod 2 == 0", resultType: "org.iso.QRCode", resultString: "Sample Data 2", resultSymbolVersion: "2", date: Date())
            ]
        }
    }

    // Prune size of scan history down to reasonable length
    func pruneScanHistory() {
        let currentCount = scanHistory.count
        if currentCount > maxScanHistory {
            scanHistory.removeSubrange(20...currentCount - 1)
        }
    }
}
