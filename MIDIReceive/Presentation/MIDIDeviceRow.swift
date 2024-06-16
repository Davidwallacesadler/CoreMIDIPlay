//
//  MIDIDeviceRow.swift
//  MIDIReceive
//
//  Created by David Sadler on 6/15/24.
//

import SwiftUI

struct MIDIDeviceRow: View {
    
    let device: MIDIDeviceModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(device.name ?? "UN-NAMED DEVICE")")
                        .font(.title3).bold()
                    if let deviceID = device.uniqueID {
                        Text("ID: \(String(describing: deviceID))")
                            .font(.footnote)
                    }
                    
                }
                
                Spacer()
                OnlineOfflineChip(isOffline: device.isOffline ?? true)
            }
            
            Divider()
            HStack {
                ValueLabel(
                    label: "Model",
                    value: device.model ?? ""
                )
                ValueLabel(
                    label: "Manufacturer",
                    value: device.manufacturer ?? ""
                )
            }
            ValueLabel(
                label: "Driver",
                value: device.driver ?? ""
            )
        }
        .padding()
    }
}

private struct ValueLabel: View {
    
    let label: String
    let value: String
    
    var valueText: String {
        value.isEmpty ? "NONE" : value
    }
    
    var body: some View {
        VStack {
            Text(label)
                .font(.headline)
            Text(valueText)
                .font(.subheadline)
                .foregroundStyle(value.isEmpty ? .gray : .primary)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct OnlineOfflineChip: View {
    
    let isOffline: Bool
    
    private var text: String {
        isOffline ? "Offline" : "Online"
    }
    
    private var color: Color {
        isOffline ? .red : .green
    }
    
    var body: some View {
        ColoredChip(text: text, tint: color)
    }
    
}

private struct ColoredChip: View {
    
    let text: String
    let tint: Color
    
    var body: some View {
        Text(text)
            .foregroundStyle(tint)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(tint.opacity(0.15))
            .clipShape(Capsule())
    }
}

#Preview {
    MIDIDeviceRow(
        device: MIDIDeviceModel(
            name: "UMD-1",
            driver: "AppleRTP",
            manufacturer: "Roland",
            model: "UMD01",
            imageURL: nil,
            isOffline: false,
            uniqueID: 1500
        )
    )
}
