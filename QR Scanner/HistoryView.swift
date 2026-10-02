//
//  HistoryView.swift
//  QR Scanner
//
//  Created by Brent Amersbach on 8/10/26.
//

import SwiftUI

struct HistoryView: View {

    @Environment(\.dismiss) var dismiss
    @StateObject var globalData: GlobalData = GlobalData()

    var body: some View {

        List {
            ForEach(globalData.scanHistory) { scanRecord in
                VStack {
//                    #if targetEnvironment(simulator)
//                    Text("1/24/1983, 10:30 AM")
//                        .bold()
//                    #else
                    Text(scanRecord.date?.formatted() ?? "")
                        .bold()
//                    #endif
                    Text(scanRecord.resultString.prefix(40))
                }
                .onTapGesture {

                }
            }
        }
        .environmentObject(globalData)
    }
}

#Preview {
    HistoryView()
        .environmentObject(GlobalData(withDemoHistory: [
            ScanRecord(resultErrorCorrectionLevel: "Whatever", resultMaskPattern: "Something", resultType: "org.iso.QRCode", resultString: "Sample Data 1", resultSymbolVersion: "1", date: Date()),
            ScanRecord(resultErrorCorrectionLevel: "Whatever", resultMaskPattern: "Something", resultType: "org.iso.QRCode", resultString: "Sample Data 2", resultSymbolVersion: "2", date: Date())
        ]))
}
