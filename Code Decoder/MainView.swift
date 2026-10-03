//
//  ContentView.swift
//  QR Scanner
//
//  Created by Brent Amersbach on 2/14/25.
//

import SwiftUI
import CodeScanner
import SwiftData

struct MainView: View {
    #if DEBUG
    var isPreview: Bool {
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
    #endif

    // Data model setup
    @Environment(\.modelContext) var modelContext
    @Query var scanHistory: [ScanRecord]
    @State private var isShowingScanner = false
    @State private var isShowingCopyConfirmation: Bool = false
    @State var currentScan: ScanRecord? = nil
    @StateObject var scanProcessor: ScanProcessor = ScanProcessor()

    // State for showing the code details
    @SceneStorage("isShowingDetails")
    private var isShowingDetails = true
    @State private var isShowingHistory = false

    // Config for copy function
    let overlayColor = Color(UIColor.secondarySystemBackground)
    let clipboard = UIPasteboard.general
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false

        switch result {
        case .success(let result):
            // Process new scan and add to history
            let newRecord = scanProcessor.processScan(for: result)
            modelContext.insert(newRecord)

            // Update ID of current scan to display to the new scan
            scanProcessor.currentScanId = newRecord.id.uuidString
            currentScan = scanHistory.first(where: { scan in
                scan.id == newRecord.id
            })

        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
    
    func copyToClipboard(_ text: String) {
        clipboard.string = currentScan?.resultString ?? ""
        isShowingCopyConfirmation.toggle()
        withAnimation(.easeOut(duration: 2.0)) {
            isShowingCopyConfirmation.toggle()
        }
    }

    func updateCurrentScan(with id: UUID) {
        if let newCurrentScan = scanHistory.first(where: { scan in
            scan.id == id
        }) {
            currentScan = newCurrentScan
        }
    }

    var body: some View {
        ZStack {
            if isShowingCopyConfirmation {
                Text("Text copied to clipboard")
                    .font(.title)
                    .padding()
                    .background(overlayColor)
                    .frame(alignment: .center)
                    .cornerRadius(20)
            }
            VStack(alignment: .center) {
                Button(action: {
                    withAnimation() {
                        isShowingDetails.toggle()
                    }
                }) {
                    Text("Code Details")
                        .font(.title)
                        .foregroundColor(.primary)
                        .padding([.top, .bottom], 8)
                }
                if isShowingDetails {
                    CodeDetailsView(currentScan: currentScan ?? nil)
                }
                
                Divider()
                
                Text("Code data:")
                    .font(.title)
                    .padding([.top, .bottom], 8)
                                
                ScrollView {
                    Divider().opacity(0)

                    if currentScan != nil {
                        Text(currentScan?.resultString ?? "")
                            .monospaced()
                            .padding(.top, 16)
                            .padding(.leading, 16)
                            .padding(.trailing, 16)
                    } else {
                        Text("Tap Scan Code to begin")
                            .opacity(0.7)
                            .padding(.leading, 16)
                            .padding(.trailing, 16)
                    }
                }
                .border(overlayColor, width: 2)
            }
            .sheet(isPresented: $isShowingScanner) {
                CodeScannerView(codeTypes: [.qr, .ean8, .ean13, .gs1DataBar, .gs1DataBarLimited, .gs1DataBarExpanded, .codabar, .code39, .code93, .code128, .code39Mod43, .itf14, .upce, .interleaved2of5], showViewfinder: true, completion: handleScan)
            }
            .sheet(isPresented: $isShowingHistory) {
                HistoryView(multiSelection: [], selection: nil)
                    .environmentObject(scanProcessor)
                    .onDisappear() {
                        if let newId = scanProcessor.currentScanId {
                            currentScan = scanHistory.first(where: { scan in
                                scan.id.uuidString == newId
                            })
                        }
                    }
            }
        }
        VStack(alignment: .center) {
            Button("Scan Code") {
                isShowingScanner = true
            }
            .font(.title)
            .padding(16)

            if currentScan != nil {
                HStack(spacing: 16) {
                    Button("Copy Data") {
                        copyToClipboard(currentScan?.resultString ?? "")
                    }
                    .font(.title2)
                    Spacer()
                        .frame(maxWidth: 20)
                    Button("Clear", role: .destructive) {
                        withAnimation() {
                            currentScan = nil
                        }
                    }
                    .font(.title2)
                }
            }
            Button("History") {
                isShowingHistory = true
            }
            .font(.title2)
            .padding(.top)
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        let globalData = ScanProcessor()
        var demoRecords: [ScanRecord] { globalData.createScanHistory() }
        var body: some View {
            MainView(
                currentScan: demoRecords.first,
            )
            .environmentObject(globalData)
        }
    }
    return PreviewWrapper()
}

