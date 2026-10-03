//
//  HistoryView.swift
//  QR Scanner
//
//  Created by Brent Amersbach on 8/10/26.
//

import SwiftUI

struct HistoryView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var globalData: GlobalData

    var body: some View {
        Section {
            List {
                ForEach(globalData.scanHistory) { scanRecord in
                    VStack {

                        Text(scanRecord.date?.formatted() ?? "")
                            .bold()
                        Text(scanRecord.resultString.prefix(40))
                    }
                    .onTapGesture {
                        if let selectedIndex = globalData.scanHistory.firstIndex(where: { scanToCheck in
                            return scanToCheck.id == scanRecord.id
                        }) {
                            globalData.currentScanIndex = selectedIndex
                            dismiss()
                        }

                    }
                }
            }
            .environmentObject(globalData)
        }
        Section {
            Button("Done") {
                dismiss()
            }
            .font(.title)
        }

    }
}

#Preview {
    HistoryView()
        .environmentObject(GlobalData(createDemoHistory: true))
}
