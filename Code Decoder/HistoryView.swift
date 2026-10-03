//
//  HistoryView.swift
//  QR Scanner
//
//  Created by Brent Amersbach on 8/10/26.
//

import SwiftUI
import SwiftData

struct HistoryView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var globalData: GlobalData
    @Environment(\.modelContext) var modelContext
    @Query var scanHistory: [ScanRecord]

    @State private var selectedScanRecord: ScanRecord? = nil
    @State var multiSelection = Set<UUID>()

    init(multiSelection: Set<UUID>, selection: ScanRecord?) {
        self.multiSelection = multiSelection
        self.selectedScanRecord = selection
    }

    func deleteScanRecord(at indexes: IndexSet) {
        for index in indexes {
            let scanToDelete = scanHistory[index]
            modelContext.delete(scanToDelete)
        }
    }

    var body: some View {
        VStack {
            List(selection: $multiSelection) {
                Section(content: {
                    ForEach(scanHistory) { scanRecord in
                        VStack {
                            Text(scanRecord.date?.formatted() ?? "")
                                .bold()
                            Text(scanRecord.resultString.prefix(40))
                        }
                        .onTapGesture {
                            if let selectedScan = scanHistory.first(where: { scanToCheck in
                                return scanToCheck.id == scanRecord.id
                            }) {
                                globalData.currentScanId = selectedScan.id.uuidString
                                dismiss()
                            }
                        }
                    }
                    .onDelete(perform: deleteScanRecord)
                }, footer: {
                    Text("Previous Scans")
                        .font(.title2)
                })
                #if DEBUG
                Button("Add record", systemImage: "plus") {
                    modelContext.insert(ScanRecord(resultErrorCorrectionLevel: "M - 15%", resultMaskPattern: "(row + column) mod 2 == 0", resultType: "org.iso.QRCode", resultString: "New Result", resultSymbolVersion: "2", date: Date()))
                }
                #endif
            }
            .environmentObject(globalData)
            .onChange(of: multiSelection) {
                selectedScanRecord = scanHistory.first(where: {$0.id == multiSelection.sorted().first})
            }

            Button("Done") {
                dismiss()
            }
            .font(.title)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ScanRecord.self, configurations: config)

    let demoRecords = GlobalData().createScanHistory()
    let context = container.mainContext
    for record in demoRecords {
        context.insert(record)
    }
    struct PreviewWrapper: View {
        let container: ModelContainer
        @State private var selectedScanRecord: ScanRecord? = nil
        @State private var multiSelection = Set<UUID>()
        
        var body: some View {
            HistoryView(multiSelection: multiSelection, selection: selectedScanRecord)
                .modelContainer(container)
                .environmentObject(GlobalData())
        }
    }

    return PreviewWrapper(container: container)
}
