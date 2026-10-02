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
    #if DEBUG
    var createDemoHistory = false
    #endif

    init() {
        self.scanHistory = []
    }

    convenience init(createDemoHistory: Bool) {
        self.init()
        if createDemoHistory {
            self.scanHistory = [
                ScanRecord(resultErrorCorrectionLevel: "Whatever", resultMaskPattern: "Something", resultType: "org.iso.QRCode", resultString: "Sample Data 1", resultSymbolVersion: "1", date: Date()),
                ScanRecord(resultErrorCorrectionLevel: "Whatever", resultMaskPattern: "Something", resultType: "org.iso.QRCode", resultString: "Sample Data 2", resultSymbolVersion: "2", date: Date())
            ]
        }
    }
    #if DEBUG
    init(withDemoHistory scanHistory: [ScanRecord]) {
        self.scanHistory = scanHistory
    }
    #endif

    func addScanRecord(for record: ScanRecord) {
        self.scanHistory.append(record)
    }
    func getLatestRecord() -> ScanRecord? {
        return self.scanHistory.last
    }
    func getCurrentScan() -> ScanRecord? {
        if currentScanIndex != nil {
            return self.scanHistory[self.currentScanIndex!]
        }
        else {
            return nil
        }
    }
}
