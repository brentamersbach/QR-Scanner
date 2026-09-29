//
//  Untitled.swift
//  QR Scanner
//
//  Created by Brent Amersbach on 8/10/26.
//
import Foundation

struct ScanRecord: Identifiable {
    let id: UUID = UUID()
    let date: Date
    let resultErrorCorrectionLevel: String
    let resultMaskPattern: String
    let resultType: String
    let resultString: String
    let resultSymbolVersion: String

    init(resultErrorCorrectionLevel: String, resultMaskPattern: String, resultType: String, resultString: String, resultSymbolVersion: String, date: Date) {
        self.resultErrorCorrectionLevel = resultErrorCorrectionLevel
        self.resultMaskPattern = resultMaskPattern
        self.resultType = resultType
        self.resultString = resultString
        self.resultSymbolVersion = resultSymbolVersion
        self.date = date
    }
}
