//
//  ContentView.swift
//  MIDIReceive
//
//  Created by David Sadler on 6/13/24.
//

import SwiftUI
import UIKit

extension Image {
    
    init(imageURL: URL) {
        let uiImage = if let imageData = try? Data(contentsOf: imageURL) {
            UIImage(data: imageData)
        } else {
            UIImage(systemName: "exclamationmark.circle")
        }
        self.init(uiImage: uiImage!)
    }
}



struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
