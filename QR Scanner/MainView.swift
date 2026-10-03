//
//  ContentView.swift
//  QR Scanner
//
//  Created by Brent Amersbach on 2/14/25.
//

import SwiftUI
import CodeScanner

struct MainView: View {
    var isPreview: Bool {
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
    
    @State private var isShowingScanner = false
    @State private var isShowingCopyConfirmation: Bool = false

    @SceneStorage("resultString")
    var resultString: String = ""
    @SceneStorage("resultType")
    private var resultType: String = ""
    @SceneStorage("resultSymbolVersion")
    private var resultSymbolVersion: String = ""
    @SceneStorage("resultMaskPattern")
    private var resultMaskPattern: String = ""
    @SceneStorage("resultErrorCorrectionLevel")
    private var resultErrorCorrectionLevel: String = ""
    @State var currentScan: ScanRecord? = nil

    @EnvironmentObject var globalData: GlobalData

    @SceneStorage("isShowingDetails")
    private var isShowingDetails = true

    @State private var isShowingHistory = false

    let overlayColor = Color(UIColor.secondarySystemBackground)
    let clipboard = UIPasteboard.general
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
       
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

                // Append new scan to history
                let newRecord = ScanRecord(resultErrorCorrectionLevel: resultErrorCorrectionLevel, resultMaskPattern: resultMaskPattern, resultType: resultType, resultString: resultString, resultSymbolVersion: resultSymbolVersion, date: Date())
                globalData.scanHistory.append(newRecord)

                // Update index of current scan to display to the new scan
                let newRecordIndex = globalData.scanHistory.endIndex - 1
                globalData.currentScanIndex = newRecordIndex
                currentScan = globalData.scanHistory[newRecordIndex]

                // Prune size of scan history
                globalData.pruneScanHistory()
            }

        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
    
    func copyToClipboard(_ text: String) {
        clipboard.string = resultString
        isShowingCopyConfirmation.toggle()
        withAnimation(.easeOut(duration: 2.0)) {
            isShowingCopyConfirmation.toggle()
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
                CodeScannerView(codeTypes: [.qr, .ean8, .ean13, .gs1DataBar, .gs1DataBarLimited, .gs1DataBarExpanded, .codabar, .code39, .code93, .code128, .code39Mod43, .itf14, .upce, .interleaved2of5], showViewfinder: true, simulatedData: "Berry cat is the cattest cat", completion: handleScan)
            }
            .sheet(isPresented: $isShowingHistory) {
                HistoryView()
                    .environmentObject(globalData)
                    .onDisappear() {
                        if let newIndex = globalData.currentScanIndex {
                            currentScan = globalData.scanHistory[newIndex]
                        }
                    }
            }
        }
        VStack(alignment: .center) {
            Button(action: {
                isShowingScanner = true
            }) {
                Text("Scan Code")
                    .font(.title)
            }
            .padding(16)
            if currentScan != nil {
                HStack(spacing: 16) {
                    Button("Copy Data") {
                        copyToClipboard(resultString)
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
    MainView(currentScan: GlobalData(createDemoHistory: true).scanHistory[0])
        .environmentObject(GlobalData(createDemoHistory: true))
}

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return self.map { String(format: format, $0) }.joined()
    }
}
