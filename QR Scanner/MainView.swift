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
    #if targetEnvironment(simulator)
    @State private var resultType: String = "org.iso.QRCode"
    @State private var resultString: String = "Hello, World! I'm a bunch of data from a QR code!"
    @State private var resultSymbolVersion: String = "3"
    @State private var resultMaskPattern: String = "( ((row + column) mod 2) + ((row * column) mod 3) ) mod 2 == 0"
    @State private var resultErrorCorrectionLevel: String = "M"
    
    #else
    @SceneStorage("resultString")
    private var resultString: String = ""
    @SceneStorage("resultType")
    private var resultType: String = ""
    @SceneStorage("resultSymbolVersion")
    private var resultSymbolVersion: String = ""
    @SceneStorage("resultMaskPattern")
    private var resultMaskPattern: String = ""
    @SceneStorage("resultErrorCorrectionLevel")
    private var resultErrorCorrectionLevel: String = ""
    #endif
    
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
                
                switch descriptor.errorCorrectionLevel {
                case .levelL:
                    resultErrorCorrectionLevel = "L"
                case .levelM:
                    resultErrorCorrectionLevel = "M"
                case .levelQ:
                    resultErrorCorrectionLevel = "Q"
                case .levelH:
                    resultErrorCorrectionLevel = "H"
                default:
                    resultErrorCorrectionLevel = "Unknown"
                }
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
            if isPreview || isShowingCopyConfirmation {
                Text("Text copied to clipboard")
                    .font(.title)
                    .padding()
                    .background(overlayColor)
                    .frame(alignment: .center)
                    .cornerRadius(20)
            }
            VStack(alignment: .center) {
                Text("Code Details")
                    .font(.title)
                    .padding([.top, .bottom], 8)
                VStack (alignment: .leading, spacing: 5) {
                    if !resultType.isEmpty {
                        HStack {
                            Text("Code type: ")
                                .font(.headline)
                            Text(resultType)
                                .monospaced()
                        }
                    }
                    if resultType == "org.iso.QRCode" {
                        HStack {
                            Text("Symbol Version: ")
                                .font(.headline)
                            Text(resultSymbolVersion)
                                .monospaced()
                            Spacer()
                        }
                        VStack(alignment: .leading) {
                                Text("Mask Pattern: ")
                                    .font(.headline)
                                Text(resultMaskPattern)
                                    .monospaced()
                            }
                        HStack {
                            Text("Error Correction Level: ")
                                .font(.headline)
                            Text(resultErrorCorrectionLevel)
                                .monospaced()
                        }
                    }
                }
                Text("Code data:")
                    .font(.title)
                    .padding([.top, .bottom], 8)
                
                ScrollView {
                    Divider().opacity(0)
                    if resultString.lengthOfBytes(using: .utf8) > 0 {
                        Text(resultString)
                            .monospaced()
                            .padding(.top, 16)
                            .padding(.leading, 16)
                            .padding(.trailing, 16)
                    } else {
                        Text("Tap Scan QR Code to begin")
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
        }
        VStack(alignment: .center) {
            Button(action: {
                isShowingScanner = true
            }) {
                Text("Scan QR Code")
                    .font(.title)
            }
            .padding(16)
            if resultString.lengthOfBytes(using: .utf8) > 0 {
                HStack(spacing: 16) {
                    Button("Copy") {
                        copyToClipboard(resultString)
                    }
                    .font(.title2)
                    Spacer()
                        .frame(maxWidth: 20)
                    Button("Clear", role: .destructive) {
                        resultString = ""
                        resultType = ""
                    }
                    .font(.title2)
                }
            }
        }
    }
}

#Preview {
    MainView()
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
