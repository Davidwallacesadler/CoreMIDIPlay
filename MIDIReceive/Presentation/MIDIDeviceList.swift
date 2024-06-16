//
//  MIDIDeviceList.swift
//  MIDIReceive
//
//  Created by David Sadler on 6/15/24.
//

import SwiftUI

struct MIDIDeviceList: View {
    
    @ObservedObject var logModel: LogModel
    
    let onQueryTapped: (PacketReceiver.QueryType) -> Void
    let onClearTapped: () -> Void
    
    @State private var isPresentingLogSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(logModel.foundDevices) { device in
                    Section {
                        MIDIDeviceRow(device: device)
                    }
                }
            }
            .overlay {
                if (logModel.foundDevices.isEmpty) {
                    Text("No Devices/Endpoints Found")
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
                        Menu("Query") {
                            ForEach(PacketReceiver.QueryType.allCases) { queryType in
                                Button {
                                    onQueryTapped(queryType)
                                } label: {
                                    Text(queryType.description)
                                }
                            }
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

#Preview {
    MIDIDeviceList(
        logModel: LogModel(),
        onQueryTapped: { _ in },
        onClearTapped: {}
    )
}
