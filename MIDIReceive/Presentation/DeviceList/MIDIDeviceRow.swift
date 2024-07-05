//
//  MIDIDeviceRow.swift
//  MIDIReceive
//
//  Created by David Sadler on 6/15/24.
//

import SwiftUI

struct MIDIDeviceRow: View {
    
    let device: MIDIDeviceModel
    let onSourceTapped: (Int, Int) -> Void
    
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
            
            Text("Properties")
                .font(.headline)
            
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
            HStack {
                ValueLabel(
                    label: "Driver",
                    value: device.driver ?? ""
                )
                
                let isUMPEnabledValue = if let isUMPEnabled = device.isUMPEnabled {
                    isUMPEnabled ? "Yes" : "No"
                } else {
                    ""
                }
                ValueLabel(
                    label: "UMP Enabled",
                    value: isUMPEnabledValue
                )
            }
            HStack {
                let isUSBMIDI2_0Value = if let isUSBMIDI2_0 = device.isUSBMIDI2_0 {
                    isUSBMIDI2_0 ? "Yes" : "No"
                } else {
                    ""
                }
                ValueLabel(
                    label: "USB MIDI 2.0",
                    value: isUSBMIDI2_0Value
                )
                
                let locationIDValue = if let usbLocationId = device.usbLocationID {
                    String(describing: usbLocationId)
                } else {
                    ""
                }
                ValueLabel(
                    label: "USB Location ID",
                    value: locationIDValue
                )
            }
            
            let usbVendorProductValue = if device.usbVendorProduct != nil {
                String(describing: device.usbVendorProduct)
            } else {
                ""
            }
            ValueLabel(
                label: "USB Vendor Product",
                value: usbVendorProductValue
            )
            
            if device.entities.isEmpty {
                Text("No Entities Found")
                    .font(.title3)
                    .foregroundStyle(Color.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical)
            } else {
                Text("Entities (\(device.entities.count))")
                    .font(.headline)
                ForEach(device.entities.indices, id: \.self) { entityIdx in
                    let entity = device.entities[entityIdx]
                    MIDIEntityRow(
                        entity: entity,
                        onSourceTapped: { sourceIdx in
                            onSourceTapped(entityIdx, sourceIdx)
                        }
                    )
                }
            }
        }
    }
}

// MARK: - Online/Offline Chip

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

// MARK: - Preview

#Preview {
    MIDIDeviceRow(
        device: MIDIDeviceModel(
            name: "UMD-1",
            driver: "AppleRTP",
            manufacturer: "Roland",
            model: "UMD01",
            imageURL: nil,
            isOffline: false,
            uniqueID: 1500,
            isUMPEnabled: false,
            isUSBMIDI2_0: false,
            usbLocationID: 10,
            usbVendorProduct: 1000,
            entities: []
        ), 
        onSourceTapped: { _, _ in }
    )
}
