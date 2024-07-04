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
            querySources()
        case .destinationEndpoints:
            queryDestinations()
        }
    }
    
    private func queryAllDevices() {
        let allDeviceCount = MIDIGetNumberOfDevices()
        logModel.print(" # Devices = \(allDeviceCount)")
        
//        traverseAndLogDeviceHeirarchy(numberOfDevices: allDeviceCount)
        traverseDevicesForDisplay(numberOfDevices: allDeviceCount)
    }
    
    private func queryExternalDevices() {
        let externalDeviceCount = MIDIGetNumberOfExternalDevices()
        logModel.print(" # Devices = \(externalDeviceCount)")
        
        traverseAndLogDeviceHeirarchy(numberOfDevices: externalDeviceCount)
    }
    
    private func traverseDevicesForDisplay(numberOfDevices: Int) {
        for i in 0..<numberOfDevices {
            let deviceRef = MIDIGetDevice(i)
            var deviceModel = extractDevice(fromRef: deviceRef)
            
            if deviceModel != nil {
                let numberOfEntities = MIDIDeviceGetNumberOfEntities(deviceRef)
                
                for j in 0..<numberOfEntities {
                    let entityRef = MIDIDeviceGetEntity(deviceRef, j)
                    var entityModel = extractEntity(fromRef: entityRef)
                    
                    if entityModel != nil {
                        let numberOfSources = MIDIEntityGetNumberOfSources(entityRef)
                        
                        for k in 0..<numberOfSources {
                            let sourceRef = MIDIEntityGetSource(entityRef, k)
                            let sourceModel = extractEndpoint(fromRef: sourceRef)
                            
                            if let sourceModel {
                                entityModel?.sources.append(sourceModel)
                            }
                        }
                        
                        let numberOfDestinations = MIDIEntityGetNumberOfDestinations(entityRef)
                        
                        for l in 0..<numberOfDestinations {
                            let destinationRef = MIDIEntityGetDestination(entityRef, l)
                            let destinationModel = extractEndpoint(fromRef: destinationRef)
                            
                            if let destinationModel {
                                entityModel?.destinations.append(destinationModel)
                            }
                        }
                        
                        deviceModel?.entities.append(entityModel!)
                    }
                }
                
                logModel.foundDevices.append(deviceModel!)
            }
        }
    }
    
    private func extractDevice(fromRef deviceRef: MIDIDeviceRef) -> MIDIDeviceModel? {
        var unmanagedObjectProps: Unmanaged<CFPropertyList>?
        let status = MIDIObjectGetProperties(
            deviceRef,
            &unmanagedObjectProps,
            false
        )
        if status != noErr {
            logModel.print("Failed to get MIDI Object properties.")
            return nil
        } else {
            let objectProps = unmanagedObjectProps?.takeRetainedValue()
            
            let device = MIDIDeviceModel.from(propertyList: objectProps)
            logModel.print(device?.description ?? "")
            return device
        }
    }
    
    private func extractEntity(fromRef entityRef: MIDIEntityRef) -> MIDIEntityModel? {
        var unmanagedObjectProps: Unmanaged<CFPropertyList>?
        let status = MIDIObjectGetProperties(
            entityRef,
            &unmanagedObjectProps,
            false
        )
        if status != noErr {
            logModel.print("Failed to get MIDI Object properties.")
            return nil
        } else {
            let objectProps = unmanagedObjectProps?.takeRetainedValue()
            
            let entity = MIDIEntityModel.from(propertyList: objectProps)
            logModel.print(entity?.description ?? "")
            return entity
        }
    }
    
    private func extractEndpoint(fromRef endpointRef: MIDIEndpointRef) -> MIDIEndpointModel? {
        var unmanagedObjectProps: Unmanaged<CFPropertyList>?
        let status = MIDIObjectGetProperties(
            endpointRef,
            &unmanagedObjectProps,
            false
        )
        if status != noErr {
            logModel.print("Failed to get MIDI Object properties.")
            return nil
        } else {
            let objectProps = unmanagedObjectProps?.takeRetainedValue()
            
            let endpoint = MIDIEndpointModel.from(propertyList: objectProps)
            logModel.print(endpoint?.description ?? "")
            return endpoint
        }
    }
    
    private func traverseAndLogDeviceHeirarchy(numberOfDevices: Int) {
        for i in 0..<numberOfDevices {
            logModel.print("Inspecting Device \(i + 1)....")
            let deviceRef = MIDIGetDevice(i)
            printAndExtractMIDIDevice(deviceRef: deviceRef)
            
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
    
    private func printAndExtractMIDIDevice(deviceRef: MIDIObjectRef) {
        var unmanagedObjectProps: Unmanaged<CFPropertyList>?
        let status = MIDIObjectGetProperties(
            deviceRef,
            &unmanagedObjectProps,
            true
        )
        if status != noErr {
            logModel.print("Failed to get MIDI Object properties.")
        } else {
            let objectProps = unmanagedObjectProps?.takeRetainedValue()
            logModel.print(objectProps?.debugDescription ?? "")
            if let device = MIDIDeviceModel.from(propertyList: objectProps) {
                logModel.foundDevices.append(device)
            }
        }
    }
    
    private func querySources() {
        let sourceCount = MIDIGetNumberOfSources()
        logModel.print(" # Sources = \(sourceCount)")
        
        for i in 0..<sourceCount {
            let sourceRef = MIDIGetSource(i)
            logModel.print("Inspecting Source Endpoint \(i + 1)....")
            
            printMIDIObjectProps(objectRef: sourceRef)
            
            let status = MIDIPortConnectSource(
                inputPort,
                sourceRef,
                nil
            )
            if status != noErr {
                logModel.print("Failed to connect port to source")
            } else {
                logModel.print("Successfully connected source to port")
            }
        }
    }
    
    private func queryDestinations() {
        let destinationCount = MIDIGetNumberOfDestinations()
        logModel.print(" # Destinations = \(destinationCount)")
        
        for i in 0..<destinationCount {
            let destinationRef = MIDIGetDestination(i)
            logModel.print("Inspecting Destination Endpoint \(i + 1)....")
            
            printMIDIObjectProps(objectRef: destinationRef)
        }
    }
    
    private func printMIDIObjectProps(objectRef: MIDIObjectRef) {
        var unmanagedObjectProps: Unmanaged<CFPropertyList>?
        let status = MIDIObjectGetProperties(
            objectRef,
            &unmanagedObjectProps,
            false
        )
        if status != noErr {
            logModel.print("Failed to get MIDI Object properties.")
        } else {
            let objectProps = unmanagedObjectProps?.takeRetainedValue()
            logModel.print(objectProps?.debugDescription ?? "")
        }
    }
    
    // MARK: - Handlers
    
    private func handleClientStateChangeNotifications(_ message: UnsafePointer<MIDINotification>) {
        DispatchQueue.main.async {
            self.logModel.print("MIDI client received state change: \(message.pointee.messageID.description)")
        }
    }
    
    private func handleReceivedMessages(eventList: UnsafePointer<MIDIEventList>, refCon: UnsafeMutableRawPointer?) {
        DispatchQueue.main.async {
            self.logModel.print("--- MESSAGE RECEIVED ---")
            self.logModel.print("Number of packets: \(eventList.pointee.numPackets)")
            self.logModel.print("Protocol raw value: \(eventList.pointee.protocol.rawValue)")
            self.logModel.print("words: \(eventList.pointee.packet.words)")
            self.logModel.print("refCon: \(refCon.debugDescription)")
        }
        
        // Iterate through the words/messages in each packet
        if eventList.pointee.protocol == ._1_0 {
            // Parse based on MIDI 1.0 spec
            // If MIDI 1.0 should be 1 word... I think...
            let eventPacket = eventList.pointee.packet
            if let messageType = eventPacket.messageType,
               let messageStatus = eventPacket.status {
                switch messageType {
                case .channelVoice1:
                    if messageStatus == .noteOn {
                        // Extract note
                        logModel.print("Got Note On message with note value \(eventPacket.noteOnValue)")
                        
                        if let note = Note(midiValue: eventPacket.noteOnValue) {
                            logModel.print("Note pressed was \(note.description)")
                        }
                    }
                default:
                    logModel.print("Got message of type \(messageType.description)")
                }
            }
        } else {
            // Parse based on MIDI 2.0 spec
        }
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
