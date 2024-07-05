//
//  MIDIMessageType+Extensions.swift
//  MIDIReceive
//
//  Created by David Sadler on 7/3/24.
//

import CoreMIDI

extension MIDIMessageType: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .utility:
            "Utility"
        case .system:
            "System"
        case .channelVoice1:
            "Channel Voice 1"
        case .sysEx:
            "System Exclusive"
        case .channelVoice2:
            "Channel Voice 2"
        case .data128:
            "Data 128"
        case .unknownF:
            "Unknown F"
        @unknown default:
            "Unknown"
        }
    }
}
