//
//  MIDIEventPacket+Extensions.swift
//  MIDIReceive
//
//  Created by David Sadler on 6/17/24.
//

import Foundation
import CoreMIDI

extension MIDIEventPacket {
    
    /// Shifts the message by 28 bits to get the message type nibble.
    ///
    /// For example, given a 32 bit word `10010000 00000000 00000000 00000000`:
    /// After the shift to the right we only have the 4 most signifgant bits (`1001`).
    var messageType: MIDIMessageType? {
        MIDIMessageType(rawValue: words.0 >> 28)
    }
    
    /// Gets the MIDI status for the packet
    ///
    /// To get only the status nibble, shift by 20 bits (the start position of the status)
    /// and then perform an AND operation to clear the message type and group nibbles.
    /// See the section `Extracting a nibble from a byte` here https://en.wikipedia.org/wiki/Nibble
    ///
    /// For example, given a 32 bit word `10010000 01110000 00000000 00000000`:
    /// After the shift we are right with `10010000 0111`. Then `10010000 0111` & `1111` -> `0111`
    var status: MIDICVStatus? {
        MIDICVStatus(rawValue: (words.0 >> 20) & 0xF)
    }
    
    var hexString: String {
        var data = Data()

        let mirror = Mirror(reflecting: words)
        let elements = mirror.children.map { $0.value }

        for (index, element) in elements.enumerated() {
            guard index < wordCount, let value = element as? UInt32 else { continue }
            
            withUnsafeBytes(of: UInt32(bigEndian: value)) {
                data.append(contentsOf: $0)
            }
        }

        return dataToHexString(data)
    }
    
    private func dataToHexString(_ data: Data) -> String {
        if data.isEmpty { return "" }
        return data.map { String(format: "%02x", $0) }.joined().uppercased()
    }
}

// MARK: - CustomStringConvertible

extension MIDIEventPacket: CustomStringConvertible {
    
    public var description: String {
        guard let messageType = messageType,
              let status = status else {
            return ""
        }
        
        switch messageType {
        case (.utility):
            return "Utility"
        case (.system):
            return "System"
        case (.channelVoice1):
            return "MIDI 1.0 Channel Voice Message (\(status.description))"
        case (.sysEx):
            return "Sysex"
        case (.channelVoice2):
            return "MIDI 2.0 Channel Voice Message (\(status.description))"
        default:
            return ""
        }
    }
}
