//
//  MIDIDeviceList.swift
//  MIDIReceive
//
//  Created by David Sadler on 6/15/24.
//

import SwiftUI

typealias DeviceEntitySourceIndicies = (deviceIndex: Int, entityIndex: Int, sourceIndex: Int)

struct MIDIDeviceList: View {
    
    @ObservedObject var logModel: LogModel
    
    let onQueryTapped: (PacketReceiver.QueryType) -> Void
    let onSourceTapped: (DeviceEntitySourceIndicies) -> Void
    let onClearTapped: () -> Void
    
    @State private var isPresentingLogSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(logModel.foundDevices.indices, id: \.self) { deviceIdx in
                    let device = logModel.foundDevices[deviceIdx]
                    Section {
                        MIDIDeviceRow(
                            device: device,
                            onSourceTapped: { entityIdx, sourceIdx in
                                onSourceTapped((deviceIdx, entityIdx, sourceIdx))
                                isPresentingLogSheet = true
                            }
                        )
                    }
                }
            }
            .overlay {
                if (logModel.foundDevices.isEmpty) {
                    Text("No Devices Found")
                        .font(.title2)
                        .foregroundStyle(Color.gray)
                }
            }
            .listStyle(.insetGrouped)
            .frame(maxWidth: .infinity)
            .background(Color.tertiarySystemBackground)
            .sheet(isPresented: $isPresentingLogSheet) {
                MIDILogView(logData: logModel.logData)
            }
            .navigationTitle("MIDI Test")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    HStack {
                        Button {
                            onQueryTapped(PacketReceiver.QueryType.devices)
                        } label: {
                            Text("Query")
                        }
                        Spacer()
                        Button {
                            isPresentingLogSheet = true
                        } label: {
                            Text("See Log")
                        }
                        Spacer()
                        Button {
                            onClearTapped()
                        } label: {
                            Text("Clear")
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    MIDIDeviceList(
        logModel: LogModel(),
        onQueryTapped: { _ in }, 
        onSourceTapped: { _ in },
        onClearTapped: {}
    )
}
