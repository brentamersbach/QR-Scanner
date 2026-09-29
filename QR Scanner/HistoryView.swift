//
//  HistoryView.swift
//  QR Scanner
//
//  Created by Brent Amersbach on 8/10/26.
//

import SwiftUI

struct HistoryView: View {

    @Environment(\.dismiss) var dismiss
    @StateObject var history: GlobalData = GlobalData()

    var body: some View {

        List {
            ForEach(history.scanHistory) { scanRecord in
                VStack {
                    #if targetEnvironment(simulator)
                    Text("1/24/1983, 10:30 AM")
                        .bold()
                    #else
                    Text(scanRecord.date.formatted())
                        .bold()
                    #endif
                    Text(scanRecord.resultString.prefix(40))
                }
                .onTapGesture {
                    
                }
            }
        }
        .environmentObject(history)
    }
}

#Preview {
    HistoryView()
        .environmentObject(GlobalData())
}
