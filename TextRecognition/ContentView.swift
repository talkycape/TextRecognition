//
//  ContentView.swift
//  TextRecognition
//
//  Created by YACHIEH LAI on 12/26/22.
//
// Using ChatGPT!

import SwiftUI

struct ContentView: View {
    @State private var recognizedText = ""
    @State private var showTextRecognitionView = true

    var body: some View {
        VStack {
            if showTextRecognitionView {
                TextRecognitionView(recognizedText: $recognizedText)
            } else {
                Text(recognizedText)
            }

            Button(action: {
                self.showTextRecognitionView.toggle()
            }) {
                Text("Capture Image")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
