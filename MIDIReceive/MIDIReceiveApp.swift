//
//  MIDIReceiveApp.swift
//  MIDIReceive
//
//  Created by David Sadler on 6/13/24.
//

import SwiftUI

@main
struct MIDIReceiveApp: App {
    
    private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            MIDIDeviceList(
                logModel: appState.logModel,
                onQueryTapped: appState.packetReceiver.processAndLogMIDIQuery,
                onClearTapped: appState.logModel.clear
            )
        }
    }
}
