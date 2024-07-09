//
//  LogModel.swift
//  MIDIReceive
//
//  Created by David Sadler on 6/15/24.
//

import Foundation

class LogModel: ObservableObject {
    
    @Published var logData: String
    @Published var foundDevices: [MIDIDeviceModel] = []
    
    init(logData: String = "") {
        self.logData = logData
    }
    
    func print(_ text: String, printToTerminal: Bool = false) {
        DispatchQueue.main.async {
            self.logData += text + "\n"
        }
        
        if printToTerminal {
            Swift.print(text)
        }
    }
    
    func clear() {
        logData.removeAll()
        foundDevices.removeAll()
    }
    
}
