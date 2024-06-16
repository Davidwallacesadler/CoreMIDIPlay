//
//  OSStatusError.swift
//  MIDIReceive
//
//  Created by David Sadler on 6/15/24.
//

import Foundation

enum OSStatusError: Int32, Error, CustomStringConvertible {
    case kMIDINotPermitted = -10844
    
    var description: String {
        switch self {
        case .kMIDINotPermitted:
            "The process does not have privileges for the requested operation."
        }
    }
}
