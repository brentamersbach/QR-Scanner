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

    init() {
//        #if targetEnvironment(simulator)
        self.scanHistory = [
            ScanRecord(resultErrorCorrectionLevel: "Whatever", resultMaskPattern: "Something", resultType: "QR", resultString: "Sample Data 1", resultSymbolVersion: "1", date: Date()),
            ScanRecord(resultErrorCorrectionLevel: "Whatever", resultMaskPattern: "Something", resultType: "QR", resultString: "Sample Data 2", resultSymbolVersion: "2", date: Date())
        ]
//        #else
//        self.scanHistory = []
//        #endif
    }

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
