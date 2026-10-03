//
//  CodeDetailsView.swift
//  QR Scanner
//
//  Created by Brent Amersbach on 9/29/26.
//

import SwiftUI

struct CodeDetailsView: View {
    var currentScan: ScanRecord?

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
    CodeDetailsView(currentScan: ScanProcessor().createScanHistory().first)
}
