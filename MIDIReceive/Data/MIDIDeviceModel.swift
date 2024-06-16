//
//  MIDIDeviceModel.swift
//  MIDIReceive
//
//  Created by David Sadler on 6/15/24.
//

import Foundation

struct MIDIDeviceModel {
    let name: String?
    let driver: String?
    let manufacturer: String?
    let model: String?
    let imageURL: URL?
    let isOffline: Bool?
    let uniqueID: Int?
}

extension MIDIDeviceModel: CustomStringConvertible {
    var description: String {
"""
_ MIDI DEVICE _
name: \(name ?? "")
driver: \(driver ?? "")
manufacturer: \(manufacturer ?? "")
model: \(model ?? "")
imageURL: \(imageURL?.debugDescription ?? "")
isOffline: \(String(describing: isOffline))
uniqueID: \(String(describing: uniqueID))
"""
    }
}

extension MIDIDeviceModel: Identifiable {
    var id: Int {
        uniqueID ?? 0
    }
}
