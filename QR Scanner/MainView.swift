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
    @State private var resultType: String = "org.iso.qrcode"
    @State private var resultString: String = "Hello, World! I'm a bunch of data from a QR code!"
    #else
    @SceneStorage("resultString")
    private var resultString: String = ""
    @SceneStorage("resultType")
    private var resultType: String = ""
    #endif
    let overlayColor = Color(UIColor.secondarySystemBackground)
    let clipboard = UIPasteboard.general
    
    func handleScan(result: Result<ScanResult, ScanError>) {
       isShowingScanner = false
       
        switch result {
        case .success(let result):
            resultString = result.string
            resultType = result.type.rawValue
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
    
    func copyToClipboard(_ text: String) {
        clipboard.string = resultString
        isShowingCopyConfirmation.toggle()
        withAnimation(.easeOut(duration: 1.5)) {
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
            VStack {
                Text("Code type: \(resultType.uppercased())")
                    .font(.headline)
                Text("Code data:")
                    .font(.headline)
                
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
            .sheet(isPresented: $isShowingScanner) {
                CodeScannerView(codeTypes: [.qr, .ean8, .ean13, .gs1DataBar, .gs1DataBarLimited, .gs1DataBarExpanded, .codabar, .code39, .code93, .code128, .code39Mod43, .itf14, .upce, .interleaved2of5], showViewfinder: true, simulatedData: "Berry cat is the cattest cat", completion: handleScan)
            }
        }
    }
}

#Preview {
    MainView()
}
