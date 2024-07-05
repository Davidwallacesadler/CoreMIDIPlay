//
//  MIDILogView.swift
//  MIDIReceive
//
//  Created by David Sadler on 6/15/24.
//

import SwiftUI

struct MIDILogView: View {
    
    let logData: String
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    var body: some View {
        NavigationStack {
            TextEditor(text: Binding { logData } set: { _ in })
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationTitle("Log")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Text("Cancel")
                        }
                    }
                }
        }
    }
}

#Preview {
    MIDILogView(logData: "hi/n:)")
}
