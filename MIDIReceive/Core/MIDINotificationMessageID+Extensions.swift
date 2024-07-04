//
//  MIDINotificationMessageID+Extensions.swift
//  MIDIReceive
//
//  Created by David Sadler on 6/17/24.
//

import CoreMIDI

extension MIDINotificationMessageID: CustomStringConvertible {
    public var description: String {
        switch self {
        case .msgSetupChanged:
            "Something about the MIDI setup changed. Ignore if you are handling specific state changes."
        case .msgObjectAdded:
            "The system added a device, entity, or endpoint."
        case .msgObjectRemoved:
            "The system removed a device, entity, or endpoint."
        case .msgPropertyChanged:
            "A property of a MIDI object changed."
        case .msgThruConnectionsChanged:
            "The system created or disposed of a persistent MIDI Thru connection."
        case .msgSerialPortOwnerChanged:
            "The system changed a serial port owner."
        case .msgIOError:
            "A driver I/O error occurred."
        @unknown default:
            "Unknown MIDI Notifcation Message ID: \(self)."
        }
    }
}
