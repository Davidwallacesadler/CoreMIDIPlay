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
    let isUMPEnabled: Bool?
    let isUSBMIDI2_0: Bool?
    let usbLocationID: Int?
    let usbVendorProduct: Int?
    
    var entities: [MIDIEntityModel]
}

// MARK: - CustomStringConvertible

extension MIDIDeviceModel: CustomStringConvertible {
    var description: String {
"""
___ MIDI DEVICE ___
name: \(name ?? "")
driver: \(driver ?? "")
manufacturer: \(manufacturer ?? "")
model: \(model ?? "")
imageURL: \(imageURL?.debugDescription ?? "")
isOffline: \(String(describing: isOffline))
uniqueID: \(String(describing: uniqueID))
isUMPEnabled: \(String(describing: isUMPEnabled))
isUSBMIDI2_0: \(String(describing: isUSBMIDI2_0))
usbLocationID: \(String(describing: usbLocationID))
usbVendorProduct: \(String(describing: usbVendorProduct))
entities: \(String(describing: entities))
"""
    }
}

// MARK: - Identifiable

extension MIDIDeviceModel: Identifiable {
    var id: Int {
        uniqueID ?? 0
    }
}

// MARK: - PropertyListCreatable

extension MIDIDeviceModel: PropertyListCreatable {
    static func from(propertyList propList: CFPropertyList?) -> Self? {
        guard let propDict = propList as? NSDictionary else { return nil }
        
        let name = propDict["name"] as? String
        let driver = propDict["driver"] as? String
        let model = propDict["model"] as? String
        let manufacturer = propDict["manufacturer"] as? String
        let isOffline = propDict["offline"] as? Bool
        let uniqueID = propDict["uniqueID"] as? Int
        let isUMPEnabled = propDict["UMP Enabled"] as? Bool
        let isUSBMIDI2_0 = propDict["USB MIDI 2.0"] as? Bool
        let usbLocationID = propDict["USBLocationID"] as? Int
        let usbVendorProduct = propDict["USBVendorProduct"] as? Int
        
        let imageText = propDict["image"] as? String
        let imageURL: URL? = if let imageText {
            URL(string: imageText)
        } else {
            nil
        }
        
        return MIDIDeviceModel(
            name: name,
            driver: driver,
            manufacturer: manufacturer,
            model: model,
            imageURL: imageURL,
            isOffline: isOffline,
            uniqueID: uniqueID,
            isUMPEnabled: isUMPEnabled,
            isUSBMIDI2_0: isUSBMIDI2_0,
            usbLocationID: usbLocationID,
            usbVendorProduct: usbVendorProduct,
            entities: []
        )
    }
}
