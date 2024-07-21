//
//  UMPManager.swift
//  MIDIReceive
//
//  Created by David Sadler on 7/10/24.
//

import Foundation
import CoreMIDI

class UMPManager: NSObject {
    
    // MARK: - Properties
    
    private var client = MIDIClientRef()
    
    private var logger: Logger
    
    private var inputPort1_0 = MIDIPortRef()
    private var inputPort2_0 = MIDIPortRef()
    
    // MARK: - Init
    
    init(logger: Logger) {
        self.logger = logger
        
        super.init()
        
        setupMIDIClient()
        setupInputPorts()
    }
    
    // MARK: - Setup
    
    private func setupMIDIClient() {
        let status = MIDIClientCreateWithBlock(
            "MIDIReceive_UMPManager_client" as CFString,
            &client,
            handleClientStateChangeNotifications
        )
        if status != noErr {
            logger.log(message: "Failed to create the MIDI client: \(status.description)", severity: .error)
        } else {
            logger.log(message:"Successfully created MIDI client", severity: .debug)
        }
    }
    
    private func setupInputPorts() {
        let status1_0 = MIDIInputPortCreateWithProtocol(
            client,
            "MIDIReceive_UMPManager_in-port_1.0" as CFString,
            MIDIProtocolID._1_0,
            &inputPort1_0,
            handleReceivedMessages
        )
        if status1_0 != noErr {
            logger.log(message: "Failed to create the MIDI 1.0 Input Port: \(status1_0.description)", severity: .error)
        } else {
            logger.log(message: "Successfully created MIDI 1.0 Input Port", severity: .debug)
        }
        let status2_0 = MIDIInputPortCreateWithProtocol(
            client,
            "MIDIReceive_UMPManager_in-port_2.0" as CFString,
            MIDIProtocolID._2_0,
            &inputPort2_0,
            handleReceivedMessages
        )
        if status2_0 != noErr {
            logger.log(message: "Failed to create the MIDI 2.0 Input Port: \(status2_0.description)", severity: .error)
        } else {
            logger.log(message: "Successfully created MIDI 2.0 Input Port", severity: .debug)
        }
    }
    
    // MARK: - Handlers
    
    private func handleClientStateChangeNotifications(_ message: UnsafePointer<MIDINotification>) {
        switch message.pointee.messageID {
        case .msgObjectAdded:
            // Check if any sources, then connect them to the appropriate input port
            let numberOfSources = MIDIGetNumberOfSources()
            if numberOfSources > 0 {
                for i in 0..<numberOfSources {
                    let sourceRef = MIDIGetSource(0)
                    
                    let connect1_0Status = MIDIPortConnectSource(
                        inputPort1_0,
                        sourceRef,
                        nil
                    )
                    
                    if connect1_0Status != noErr {
                        logger.log(message: "Failed to connect source to the MIDI 1.0 Input Port: \(connect1_0Status.description)... Attempting 2.0 port", severity: .error)
                        
                        let connect2_0Status = MIDIPortConnectSource(
                            inputPort2_0,
                            sourceRef,
                            nil
                        )
                        
                        if connect2_0Status != noErr {
                            logger.log(message: "Failed to connect source to the MIDI 2.0 Input Port: \(connect1_0Status.description)... CONNECTION FAILED!!!", severity: .error)
                        } else {
                            logger.log(message: "Successfully connected the source to the MIDI 2.0 Input Port", severity: .debug)
                            return
                        }
                    } else {
                        logger.log(message: "Successfully connected the source to the MIDI 1.0 Input Port", severity: .debug)
                    }
                }
            }
        default:
            logger.log(message: "MIDI client received state change: \(message.pointee.messageID.description)", severity: .debug)
        }
        
        // TODO: If new device detected query for source and attempt to connect
        // TODO: Keep track of current device connection? to remove device when disconnected
    }
    
    private func handleReceivedMessages(eventList: UnsafePointer<MIDIEventList>, refCon: UnsafeMutableRawPointer?) {
        let eventPacket = eventList.pointee.packet
        
        logger.log(message: "--- MESSAGE RECEIVED ---", severity: .debug)
        logger.log(message: eventPacket.description, severity: .debug)
        logger.log(message: "Number of packets: \(eventList.pointee.numPackets)", severity: .debug)
        logger.log(message: "words: \(eventList.pointee.packet.words)", severity: .debug)
        
        if eventList.pointee.protocol == ._1_0 {
            handle1_0Packet(eventPacket)
        } else {
            handle2_0Packet(eventPacket)
        }
    }
    
    private func handle1_0Packet(_ eventPacket: MIDIEventPacket) {
        guard let messageType = eventPacket.messageType,
              let messageStatus = eventPacket.status else { return }
        
        switch messageType {
        case .channelVoice1:
            if messageStatus == .noteOn || messageStatus == .noteOff {
                let noteValue = eventPacket.words.0 >> 8 & 0xFF
                let velocityValue = eventPacket.words.0 & 0xFF
                let keyActionDescription = if messageStatus == .noteOn {
                    velocityValue != 0 ? "pressed" : "released"
                } else {
                    "released"
                }
                
                logger.log(message: "note \(noteValue), velocity \(velocityValue)", severity: .debug)
                
                if let note = Note(midiValue: noteValue) {
                    logger.log(message: "\(note.description) \(keyActionDescription)", severity: .debug)
                }
            }
        default:
            logger.log(message: "MIDI 1.0 -- MESSAGE NOT HANDLED", severity: .debug)
        }
    }
    
    private func handle2_0Packet(_ eventPacket: MIDIEventPacket) {
        guard let messageType = eventPacket.messageType,
              let messageStatus = eventPacket.status else { return }
        
        switch messageType {
        default:
            logger.log(message: "MIDI 2.0 -- MESSAGE NOT HANDLED", severity: .debug)
        }
    }
}
