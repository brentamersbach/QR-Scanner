//
//  CodeDetailsView.swift
//  QR Scanner
//
//  Created by Brent Amersbach on 9/29/26.
//

import SwiftUI

struct CodeDetailsView: View {
//    var currentScan: ScanRecord
//    @SceneStorage("resultType")
//    var resultType: String = ""
//    @SceneStorage("resultSymbolVersion")
//    var resultSymbolVersion: String = ""
//    @SceneStorage("resultMaskPattern")
//    var resultMaskPattern: String = ""
//    @SceneStorage("resultErrorCorrectionLevel")
//    var resultErrorCorrectionLevel: String = ""
    var currentScan: ScanRecord?
//    @EnvironmentObject private var globalData: GlobalData

    var body: some View {
        VStack (alignment: .leading, spacing: 5) {
            if currentScan != nil {
                HStack {
                    Text("Code type: ")
                        .fontWeight(.bold)
                    Text(currentScan?.resultType ?? "")
                        .monospaced()
                }
            }
            if currentScan?.resultType == "org.iso.QRCode" {
                HStack {
                    Text("Symbol Version: ")
                        .fontWeight(.bold)
                    Text(currentScan?.resultSymbolVersion ?? "")
                        .monospaced()
                    Spacer()
                }
                VStack(alignment: .leading) {
                    Text("Mask Pattern: ")
                        .fontWeight(.bold)
                    Text(currentScan?.resultMaskPattern ?? "")
                        .monospaced()
                }
                HStack {
                    Text("Error Correction Level: ")
                        .fontWeight(.bold)
                    Text(currentScan?.resultErrorCorrectionLevel ?? "")
                        .monospaced()
                }
            }
        }
        .padding([.leading, .trailing], 8)
    }
}

#Preview {
//    CodeDetailsView(resultType: "org.iso.QRCode", resultSymbolVersion: "3", resultMaskPattern: "( ((row + column) mod 2) + ((row * column) mod 3) ) mod 2 == 0", resultErrorCorrectionLevel: "org.iso.QRCode")
    CodeDetailsView(currentScan: ScanRecord(resultErrorCorrectionLevel: "Whatever", resultMaskPattern: "Something", resultType: "org.iso.QRCode", resultString: "Sample Data 1", resultSymbolVersion: "1", date: Date()))
//        .environment(\.ScanRecord, ScanRecord(resultErrorCorrectionLevel: "Whatever", resultMaskPattern: "Something", resultType: "QR", resultString: "Sample Data 1", resultSymbolVersion: "1", date: Date()))
}
