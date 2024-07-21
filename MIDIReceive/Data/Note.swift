//
//  Note.swift
//  MIDIReceive
//
//  Created by David Sadler on 7/3/24.
//

import Foundation

struct Note {
    
    let midiValue: UInt32 // TODO: UInt8
    
    let pitch: Pitch
    let octave: Octave
    
    init(pitch: Pitch, octave: Octave) {
        self.midiValue = UInt32(pitch.rawValue + (12 * (octave.rawValue + 1)))
        self.pitch = pitch
        self.octave = octave
    }
    
    init?(midiValue: UInt32) {
        guard let octave = Octave(rawValue: Int(midiValue) / 12),
              let pitch = Pitch(rawValue: Int(midiValue) % 12) else { return nil }
        
        self.midiValue = midiValue
        self.pitch = pitch
        self.octave = octave
    }
}

// MARK: - Internal Types

extension Note {
    
    enum Pitch: Int, CustomStringConvertible, CaseIterable {
        case c, cSharpDFlat, d, dSharpEFlat, e, f, fSharpGFlat, g, gSharpAFlat, a, aSharpBFlat, b
        
        var description: String {
            switch self {
            case .c:
                "C"
            case .cSharpDFlat:
                "C#/Db"
            case .d:
                "D"
            case .dSharpEFlat:
                "D#/Eb"
            case .e:
                "E"
            case .f:
                "F"
            case .fSharpGFlat:
                "F#/Gb"
            case .g:
                "G"
            case .gSharpAFlat:
                "G#/Ab"
            case .a:
                "A"
            case .aSharpBFlat:
                "A#/Bb"
            case .b:
                "B"
            }
        }
    }
    
    enum Octave: Int, CustomStringConvertible {
        case dblContra, subContra, contra, great, small, oneLine, twoLine, threeLine, fourLine, fiveLine, sixLine
        
        var description: String {
            "\(self.rawValue - 1)"
        }
    }
}

// MARK: - Custom String Convertible

extension Note: CustomStringConvertible {
    
    var description: String {
        pitch.description + octave.description
    }
}
