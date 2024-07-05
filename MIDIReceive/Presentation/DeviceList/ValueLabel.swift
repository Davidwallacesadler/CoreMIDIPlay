//
//  ValueLabel.swift
//  MIDIReceive
//
//  Created by David Sadler on 6/16/24.
//

import SwiftUI

struct ValueLabel: View {
    
    let label: String
    let value: String
    
    var valueText: String {
        value.isEmpty ? "NONE" : value
    }
    
    var body: some View {
        VStack {
            Text(label)
                .bold()
            Text(valueText)
                .foregroundStyle(value.isEmpty ? .gray : .primary)
        }
        .font(.footnote)
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
    }
}

#Preview {
    ValueLabel(label: "Label", value: "value")
}
