//
//  MIDIDeviceList.swift
//  MIDIReceive
//
//  Created by David Sadler on 6/15/24.
//

import SwiftUI

struct MIDIDeviceList: View {
    
    @ObservedObject var logModel: LogModel
    
    let onQueryTapped: () -> Void
    let onClearTapped: () -> Void
    
    @State private var isPresentingLogSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(logModel.foundDevices) { device in
                    MIDIDeviceRow(device: device)
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
                            onQueryTapped()
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

#Preview {
    MIDIDeviceList(
        logModel: LogModel(),
        onQueryTapped: {},
        onClearTapped: {}
    )
}
