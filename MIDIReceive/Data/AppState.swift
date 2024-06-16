//
//  AppState.swift
//  MIDIReceive
//
//  Created by David Sadler on 6/15/24.
//

import Foundation

class AppState {
    var packetReceiver: PacketReceiver
    var logModel: LogModel
    
    init(logModel: LogModel = LogModel()) {
        self.logModel = logModel
        self.packetReceiver = PacketReceiver(logModel: logModel)
    }
}
