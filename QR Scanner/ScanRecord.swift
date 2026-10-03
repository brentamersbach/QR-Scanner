//
//  Untitled.swift
//  QR Scanner
//
//  Created by Brent Amersbach on 8/10/26.
//
import Foundation
import SwiftData

@Model
class ScanRecord: Identifiable {
    @Attribute(.unique) private(set) var id: UUID = UUID()
    private(set) var date: Date?
    private(set) var resultErrorCorrectionLevel: String
    private(set) var resultMaskPattern: String
    private(set) var resultType: String
    private(set) var resultString: String
    private(set) var resultSymbolVersion: String

    init(resultErrorCorrectionLevel: String, resultMaskPattern: String, resultType: String, resultString: String, resultSymbolVersion: String, date: Date?) {
        self.resultErrorCorrectionLevel = resultErrorCorrectionLevel
        self.resultMaskPattern = resultMaskPattern
        self.resultType = resultType
        self.resultString = resultString
        self.resultSymbolVersion = resultSymbolVersion
        self.date = date
    }
}
