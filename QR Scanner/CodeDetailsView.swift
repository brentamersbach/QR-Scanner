//
//  CodeDetailsView.swift
//  QR Scanner
//
//  Created by Brent Amersbach on 9/29/26.
//

import SwiftUI

struct CodeDetailsView: View {
//    var currentScan: ScanRecord
    @SceneStorage("resultType")
    var resultType: String = ""
    @SceneStorage("resultSymbolVersion")
    var resultSymbolVersion: String = ""
    @SceneStorage("resultMaskPattern")
    var resultMaskPattern: String = ""
    @SceneStorage("resultErrorCorrectionLevel")
    var resultErrorCorrectionLevel: String = ""

    var body: some View {
        VStack (alignment: .leading, spacing: 5) {
            if !resultType.isEmpty {
                HStack {
                    Text("Code type: ")
                        .fontWeight(.bold)
                    Text(resultType)
                        .monospaced()
                }
            }
            if resultType == "org.iso.QRCode" {
                HStack {
                    Text("Symbol Version: ")
                        .fontWeight(.bold)
                    Text(resultSymbolVersion)
                        .monospaced()
                    Spacer()
                }
                VStack(alignment: .leading) {
                    Text("Mask Pattern: ")
                        .fontWeight(.bold)
                    Text(resultMaskPattern)
                        .monospaced()
                }
                HStack {
                    Text("Error Correction Level: ")
                        .fontWeight(.bold)
                    Text(resultErrorCorrectionLevel)
                        .monospaced()
                }
            }
        }
        .padding([.leading, .trailing], 8)
    }
}

#Preview {
    CodeDetailsView(resultType: "org.iso.QRCode", resultSymbolVersion: "3", resultMaskPattern: "( ((row + column) mod 2) + ((row * column) mod 3) ) mod 2 == 0", resultErrorCorrectionLevel: "org.iso.QRCode")
}
