//
//  History.swift
//  QR Scanner
//
//  Created by Brent Amersbach on 8/10/26.
//

import Foundation
import CodeScanner
import SwiftData
import CoreImage

/// Processes the raw ScanResult from CodeScanner and returns the more simple ScanRecord for use in views and storage in app's model
class ScanProcessor: ObservableObject {

    // TODO: Move this to MainView, it doesn't really need to be here
    @Published var currentScanId: String?

    func createScanHistory() -> [ScanRecord] {
        return [
            ScanRecord(resultErrorCorrectionLevel: "M - 15%", resultMaskPattern: "(row + column) mod 2 == 0", resultType: "org.iso.QRCode", resultString: "Sample Data 1", resultSymbolVersion: "2", date: Date()),
            ScanRecord(resultErrorCorrectionLevel: "M - 15%", resultMaskPattern: "(row + column) mod 2 == 0", resultType: "org.iso.QRCode", resultString: "Sample Data 2", resultSymbolVersion: "2", date: Date()),
            ScanRecord(resultErrorCorrectionLevel: "M - 15%", resultMaskPattern: "(row + column) mod 2 == 0", resultType: "org.iso.QRCode", resultString: "Sample Data 3", resultSymbolVersion: "2", date: Date())
        ]
    }

    func processScan(for result: ScanResult) -> ScanRecord {
        var resultString: String = ""
        var resultType: String = ""
        var resultSymbolVersion: String = ""
        var resultMaskPattern: String = ""
        var resultErrorCorrectionLevel: String = ""

        resultString = result.string
        resultType = result.type.rawValue
        if let descriptor = result.descriptor as? CIQRCodeDescriptor {
            resultSymbolVersion = String(descriptor.symbolVersion)

            // Map numeric mask pattern id to string
            switch descriptor.maskPattern {
            case 0:
                resultMaskPattern = "(row + column) mod 2 == 0"
            case 1:
                resultMaskPattern = "(row) mod 2 == 0"
            case 2:
                resultMaskPattern = "(column) mod 3 == 0"
            case 3:
                resultMaskPattern = "(row + column) mod 3 == 0"
            case 4:
                resultMaskPattern = "( floor(row / 2) + floor(column / 3) ) mod 2 == 0"
            case 5:
                resultMaskPattern = "((row * column) mod 2) + ((row * column) mod 3) == 0"
            case 6:
                resultMaskPattern = "( ((row * column) mod 2) + ((row * column) mod 3) ) mod 2 == 0"
            case 7:
                resultMaskPattern = "( ((row + column) mod 2) + ((row * column) mod 3) ) mod 2 == 0"
            default:
                resultMaskPattern = "Unknown"
            }

            // Map numeric error correction level to string
            switch descriptor.errorCorrectionLevel {
            case .levelL:
                resultErrorCorrectionLevel = "L - 7%"
            case .levelM:
                resultErrorCorrectionLevel = "M - 15%"
            case .levelQ:
                resultErrorCorrectionLevel = "Q - 25%"
            case .levelH:
                resultErrorCorrectionLevel = "H - 30%"
            default:
                resultErrorCorrectionLevel = "Unknown"
            }
        }

        // Create and return scan record
        let newRecord = ScanRecord(resultErrorCorrectionLevel: resultErrorCorrectionLevel, resultMaskPattern: resultMaskPattern, resultType: resultType, resultString: resultString, resultSymbolVersion: resultSymbolVersion, date: Date())
        return newRecord
    }
}
