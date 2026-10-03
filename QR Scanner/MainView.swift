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

    @Environment(\.modelContext) var modelContext
    @Query var scanHistory: [ScanRecord]
    @State private var isShowingScanner = false
    @State private var isShowingCopyConfirmation: Bool = false
    @State var currentScan: ScanRecord? = nil

    @StateObject var globalData: GlobalData = GlobalData()

    @SceneStorage("isShowingDetails")
    private var isShowingDetails = true

    @State private var isShowingHistory = false

    let overlayColor = Color(UIColor.secondarySystemBackground)
    let clipboard = UIPasteboard.general
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false

        var resultString: String = ""
        var resultType: String = ""
        var resultSymbolVersion: String = ""
        var resultMaskPattern: String = ""
        var resultErrorCorrectionLevel: String = ""

        switch result {
        case .success(let result):
            resultString = result.string
            resultType = result.type.rawValue
            if let descriptor = result.descriptor as? CIQRCodeDescriptor {
                resultSymbolVersion = String(descriptor.symbolVersion)

                // Map numeric mask pattern id to string
                switch descriptor.maskPattern {
                case 0:
                    resultMaskPattern = "(row + column) mod 2 == 0"
                case 1:
                    resultMaskPattern = "(row) mod 2 == 0"
                case 2:
                    resultMaskPattern = "(column) mod 3 == 0"
                case 3:
                    resultMaskPattern = "(row + column) mod 3 == 0"
                case 4:
                    resultMaskPattern = "( floor(row / 2) + floor(column / 3) ) mod 2 == 0"
                case 5:
                    resultMaskPattern = "((row * column) mod 2) + ((row * column) mod 3) == 0"
                case 6:
                    resultMaskPattern = "( ((row * column) mod 2) + ((row * column) mod 3) ) mod 2 == 0"
                case 7:
                    resultMaskPattern = "( ((row + column) mod 2) + ((row * column) mod 3) ) mod 2 == 0"
                default:
                    resultMaskPattern = "Unknown"
                }

                // Map numeric error correction level to string
                switch descriptor.errorCorrectionLevel {
                case .levelL:
                    resultErrorCorrectionLevel = "L - 7%"
                case .levelM:
                    resultErrorCorrectionLevel = "M - 15%"
                case .levelQ:
                    resultErrorCorrectionLevel = "Q - 25%"
                case .levelH:
                    resultErrorCorrectionLevel = "H - 30%"
                default:
                    resultErrorCorrectionLevel = "Unknown"
                }

                // Add new scan to history
                let newRecord = ScanRecord(resultErrorCorrectionLevel: resultErrorCorrectionLevel, resultMaskPattern: resultMaskPattern, resultType: resultType, resultString: resultString, resultSymbolVersion: resultSymbolVersion, date: Date())
                modelContext.insert(newRecord)

                // Update ID of current scan to display to the new scan
                globalData.currentScanId = newRecord.id.uuidString
                currentScan = scanHistory.first(where: { scan in
                    scan.id == newRecord.id
                })
            }

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
                HistoryView()
                    .environmentObject(globalData)
                    .onDisappear() {
                        if let newId = globalData.currentScanId {
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
    MainView(currentScan: GlobalData().createScanHistory().first)
        .environmentObject(GlobalData())
}

