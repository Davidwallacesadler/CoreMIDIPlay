//
//  MIDIEndpointModel.swift
//  MIDIReceive
//
//  Created by David Sadler on 6/16/24.
//

import Foundation

struct MIDIEndpointModel {
    let uniqueID: Int?
}

// MARK: - CustomStringConvertible

extension MIDIEndpointModel: CustomStringConvertible {
    var description: String {
"""
___ MIDI ENDPOINT ___
uniqueID: \(String(describing: uniqueID))
"""
    }
}


// MARK: - Identifiable

extension MIDIEndpointModel: Identifiable {
    var id: Int {
        uniqueID ?? 0
    }
}

// MARK: - PropertyListCreatable

extension MIDIEndpointModel: PropertyListCreatable {
    static func from(propertyList propList: CFPropertyList?) -> Self? {
        guard let propDict = propList as? NSDictionary else { return nil }
        
        let uniqueID = propDict["uniqueID"] as? Int
        
        return MIDIEndpointModel(
            uniqueID: uniqueID
        )
    }
}

