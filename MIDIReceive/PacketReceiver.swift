//
//  PacketReceiver.swift
//  MIDIReceive
//
//  Created by David Sadler on 6/13/24.
//

import Foundation
import CoreMIDI

/*
 Notes:
 Below are a list of the major players noted in the Apple docs.
 
 - MIDI Driver - Owns & Controls MIDI Devices
 - MIDI Devices can have sub-devices. Each one is a MIDI Entity.
 - MIDI Entity can have many MIDI Endpoints.
 - MIDI Endpoint is a 16-channel source/destination MIDI stream.
 - Core MIDI talks with the MIDI Server through IPC.
 - MIDI Server loads the MIDI Driver and manages communication with it.
 */

class PacketReceiver: NSObject {
    
    // MARK: - Properties
    
    static private let clientName = "Packet Receiver"
    static private let inputPortName = "Test Port"
    
    private var client = MIDIClientRef()
    private var clientProperties: Unmanaged<CFPropertyList>?
    
    private var logModel: LogModel
    
    private var inputPort = MIDIPortRef()
    
    // MARK: - Init
    
    init(logModel: LogModel) {
        self.logModel = logModel
        
        super.init()
        
        setupMIDIClient()
        setupInputPort()
    }
    
    // MARK: - Setup
    
    private func setupMIDIClient() {
        let status = MIDIClientCreateWithBlock(
            Self.clientName as CFString,
            &client,
            handleClientStateChangeNotifications
        )
        if status != noErr {
            logModel.print("Failed to create the MIDI client: \(status.description)")
        } else {
            logModel.print("Successfully created MIDI client")
        }
    }
    
    private func setupInputPort() {
        let status = MIDIInputPortCreateWithProtocol(
            client,
            Self.inputPortName as CFString,
            MIDIProtocolID._1_0,
            &inputPort,
            handleReceivedMessages
        )
        if status != noErr {
            logModel.print("Failed to create the MIDI Input Port: \(status.description)")
        } else {
            logModel.print("Successfully created MIDI Input Port")
        }
    }
    
    // MARK: - Queries
    
    func processAndLogMIDIQuery(type queryType: QueryType) {
        logModel.clear()
        
        logModel.print("Querying \(queryType.description)...")
        switch queryType {
        case .devices:
            queryAllDevices()
        case .externalDevices:
            queryExternalDevices()
        case .sourceEndpoints:
            logModel.print("--- NOT IMPLEMENTED ---")
        case .destinationEndpoints:
            logModel.print("--- NOT IMPLEMENTED ---")
        }
    }
    
    private func queryAllDevices() {
        let allDeviceCount = MIDIGetNumberOfDevices()
        logModel.print(" # Devices = \(allDeviceCount)")
        
        traverseAndLogDeviceHeirarchy(numberOfDevices: allDeviceCount)
    }
    
    private func queryExternalDevices() {
        let externalDeviceCount = MIDIGetNumberOfExternalDevices()
        logModel.print(" # Devices = \(externalDeviceCount)")
        
        traverseAndLogDeviceHeirarchy(numberOfDevices: externalDeviceCount)
    }
    
    private func traverseAndLogDeviceHeirarchy(numberOfDevices: Int) {
        for i in 0..<numberOfDevices {
            logModel.print("Inspecting Device \(i + 1)....")
            let deviceRef = MIDIGetDevice(i)
            printMIDIObjectProps(objectRef: deviceRef)
            
            let numberOfEntities = MIDIDeviceGetNumberOfEntities(deviceRef)
            logModel.print("\(numberOfEntities) Entities \(numberOfEntities == 0 ? "(ERROR)" : "")")
            
            for j in 0..<numberOfEntities {
                let entityRef = MIDIDeviceGetEntity(deviceRef, j)
                printMIDIObjectProps(objectRef: entityRef)
                
                let numberOfSources = MIDIEntityGetNumberOfSources(entityRef)
                logModel.print("\(numberOfSources) Sources \(numberOfSources == 0 ? "(ERROR)" : "")")
                
                
                for k in 0..<numberOfSources {
                    let sourceRef = MIDIEntityGetSource(entityRef, k)
                    printMIDIObjectProps(objectRef: sourceRef)
                }
                
                let numberOfDestinations = MIDIEntityGetNumberOfDestinations(entityRef)
                logModel.print("\(numberOfDestinations) Destinations \(numberOfDestinations == 0 ? "(ERROR)" : "")")
                
                for l in 0..<numberOfDestinations {
                    let destinationRef = MIDIEntityGetDestination(entityRef, l)
                    printMIDIObjectProps(objectRef: destinationRef)
                }
            }
        }
        
        logModel.print("----------------")
    }
    
    private func printMIDIObjectProps(objectRef: MIDIObjectRef) {
        var unmanagedObjectProps: Unmanaged<CFPropertyList>?
        let status = MIDIObjectGetProperties(
            objectRef,
            &unmanagedObjectProps,
            true
        )
        if status != noErr {
            logModel.print("Failed to get MIDI Object properties.")
        } else {
            let objectProps = unmanagedObjectProps?.takeRetainedValue()
            if let device = extractDeviceFromObject(propList: objectProps) {
                logModel.foundDevices.append(device)
            }
            logModel.print(objectProps?.debugDescription ?? "")
            
        }
    }
    
    private func extractDeviceFromObject(propList: CFPropertyList?) -> MIDIDeviceModel? {
        guard let propDict = propList as? NSDictionary else { return nil }
        
        let name = propDict["name"] as? String
        let driver = propDict["driver"] as? String
        let model = propDict["model"] as? String
        let manufacturer = propDict["manufacturer"] as? String
        let isOffline = propDict["offline"] as? Bool
        let uniqueID = propDict["uniqueID"] as? Int
        
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
            uniqueID: uniqueID
        )
    }
    
    // MARK: - Handlers
    
    private func handleClientStateChangeNotifications(_ message: UnsafePointer<MIDINotification>) {
        logModel.print("MIDI RECEIVER:: MIDI client received state change with ID: \(message.pointee.messageID)")
    }
    
    private func handleReceivedMessages(eventList: UnsafePointer<MIDIEventList>, refCon: UnsafeMutableRawPointer?) {
        print("--- MESSAGE RECEIVED ---")
        print("Number of packets: \(eventList.pointee.numPackets)")
        print("Protocol raw value: \(eventList.pointee.protocol.rawValue)")
        print("words: \(eventList.pointee.packet.words)")
        print("refCon: \(refCon.debugDescription)")
    }
    
    // MARK: - Nested Types
    
    enum QueryType: Int, Identifiable, CaseIterable, CustomStringConvertible {
        case devices,
             externalDevices, 
             sourceEndpoints,
             destinationEndpoints
        
        var id: Int { self.rawValue }
        
        var description: String {
            switch self {
            case .devices:
                "All Devices"
            case .externalDevices:
                "External Devices"
            case .sourceEndpoints:
                "Sources"
            case .destinationEndpoints:
                "Destinations"
            }
        }
    }
}
