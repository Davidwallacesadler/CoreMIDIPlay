//
//  MIDIEntityModel.swift
//  MIDIReceive
//
//  Created by David Sadler on 6/16/24.
//

import Foundation

struct MIDIEntityModel {
    let name: String?
    let uniqueID: Int?
    let `protocol`: Int?
    let inEndpoint: Int?
    let outEndpoint: Int?
    let maxSystemExclusiveSpeed: Int?
    let isCable: Bool?
    let isEmbedded: Bool?
    
    var sources: [MIDIEndpointModel]
    var destinations: [MIDIEndpointModel]
}

// MARK: - CustomStringConvertible

extension MIDIEntityModel: CustomStringConvertible {
    var description: String {
"""
___ MIDI ENTITY ___
name: \(name ?? "")
uniqueID: \(String(describing: uniqueID))
protocol: MIDI \(String(describing: self.protocol))
inEndpoint: \(String(describing: inEndpoint))
outEndpoint: \(String(describing: outEndpoint))
maxSystemExclusiveSpeed: \(String(describing: maxSystemExclusiveSpeed))
isCable: \(String(describing: isCable))
isEmbedded: \(String(describing: isEmbedded))
sources: \(String(describing: sources))
destinations: \(String(describing: destinations))
"""
    }
}

// MARK: - Identifiable

extension MIDIEntityModel: Identifiable {
    var id: Int {
        uniqueID ?? 0
    }
}

// MARK: - PropertyListCreatable

extension MIDIEntityModel: PropertyListCreatable {
    static func from(propertyList propList: CFPropertyList?) -> Self? {
        guard let propDict = propList as? NSDictionary else { return nil }
        
        let name = propDict["name"] as? String
        let uniqueID = propDict["uniqueID"] as? Int
        let `protocol` = propDict["protocol"] as? Int
        let inEndpoint = propDict["In Endpoint"] as? Int
        let outEndpoint = propDict["Out Endpoint"] as? Int
        let maxSystemExclusiveSpeed = propDict["maxSysExSpeed"] as? Int
        let isCable = propDict["Cable"] as? Bool
        let isEmbedded = propDict["embedded"] as? Bool
        
        return MIDIEntityModel(
            name: name,
            uniqueID: uniqueID,
            protocol: `protocol`,
            inEndpoint: inEndpoint,
            outEndpoint: outEndpoint,
            maxSystemExclusiveSpeed: maxSystemExclusiveSpeed,
            isCable: isCable,
            isEmbedded: isEmbedded,
            sources: [],
            destinations: []
        )
    }
}
