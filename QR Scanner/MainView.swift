//
//  ContentView.swift
//  QR Scanner
//
//  Created by Brent Amersbach on 2/14/25.
//

import SwiftUI
import CodeScanner

struct MainView: View {
    
    @State private var isShowingScanner = false
    @State private var resultString: String = ""
    
    func handleScan(result: Result<ScanResult, ScanError>) {
       isShowingScanner = false
       
        switch result {
        case .success(let result):
            resultString = result.string
            print(resultString)
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }

    var body: some View {
        VStack {
            Button(action: {
                isShowingScanner = true
            }) {
                Text("Scan QR Code")
                    .font(.title)
            }
            .padding(16)
            Text("Code data:")
                .font(.headline)
            ScrollView {
                Text(resultString)
            }
        }
        .sheet(isPresented: $isShowingScanner) {
            CodeScannerView(codeTypes: [.qr], simulatedData: "Berry cat is the cattest cat", completion: handleScan)
        }
    }
}

#Preview {
    MainView()
}
