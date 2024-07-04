//
//  MIDICVStatus+Extensions.swift
//  MIDIReceive
//
//  Created by David Sadler on 6/17/24.
//

import Foundation
import CoreMIDI

extension MIDICVStatus: CustomStringConvertible {
    
    public var description: String {
        switch self {
        // MIDI 1.0
        case .noteOff:
            "Note Off"
        case .noteOn:
            "Note On"
        case .polyPressure:
            "Poly Pressure"
        case .controlChange:
            "Control Change"
        case .programChange:
            "Program Change"
        case .channelPressure:
            "Channel Pressure"
        case .pitchBend:
            "Pitch Bend"
        // MIDI 2.0
        case .registeredPNC:
            "Registered PNC"
        case .assignablePNC:
            "Assignable PNC"
        case .registeredControl:
            "Registered Control"
        case .assignableControl:
            "Assignable Control"
        case .relRegisteredControl:
            "Rel Registered Control"
        case .relAssignableControl:
            "Rel Assignable Control"
        case .perNotePitchBend:
            "Per Note PitchBend"
        case .perNoteMgmt:
            "Per Note Mgmt"
        default:
            ""
        }
    }
}
