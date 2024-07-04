//
//  MIDIEntityRow.swift
//  MIDIReceive
//
//  Created by David Sadler on 6/16/24.
//

import SwiftUI

struct MIDIEntityRow: View {
    
    let entity: MIDIEntityModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(entity.name ?? "UN-NAMED ENTITY")")
                        .font(.subheadline).bold()
                    if let entityID = entity.uniqueID {
                        Text("ID: \(String(describing: entityID))")
                            .font(.footnote)
                    }
                    
                }
                
                Spacer()
            }
            HStack {
                let protocolValue = if let entityProtocol = entity.protocol {
                    String(describing: entityProtocol)
                } else {
                    ""
                }
                ValueLabel(
                    label: "Protocol",
                    value: protocolValue
                )
                
                let maxSysExSpeedValue = if let maxSysExSpeed = entity.maxSystemExclusiveSpeed {
                    String(describing: maxSysExSpeed)
                } else {
                    ""
                }
                ValueLabel(
                    label: "Max SysEx Speed",
                    value: maxSysExSpeedValue
                )
            }
            HStack {
                let inEndpointValue = if let inEndpoint = entity.inEndpoint {
                    String(describing: inEndpoint)
                } else {
                    ""
                }
                ValueLabel(
                    label: "In Endpoint",
                    value: inEndpointValue
                )
                
                let outEndpointValue = if let outEndpoint = entity.outEndpoint {
                    String(describing: outEndpoint)
                } else {
                    ""
                }
                ValueLabel(
                    label: "Out Endpoint",
                    value: outEndpointValue
                )
            }
            HStack {
                let isCableValue = if let isCable = entity.isCable {
                    isCable ? "Yes" : "No"
                } else {
                    ""
                }
                ValueLabel(
                    label: "Cable",
                    value: isCableValue
                )
                
                let embedded = if let isEmbedded = entity.isEmbedded {
                    isEmbedded ? "Yes" : "No"
                } else {
                    ""
                }
                ValueLabel(
                    label: "Embedded",
                    value: embedded
                )
            }
            
            Text("Endpoints (\(entity.sources.count + entity.destinations.count))")
                .font(.subheadline).bold()
            
            if entity.sources.isEmpty {
                Text("No Sources")
                    .font(.title3)
                    .foregroundStyle(Color.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical)
            } else {
                ForEach(entity.sources) { source in
                    let uniqueIDValue = if let uniqueID = source.uniqueID {
                        String(describing: uniqueID)
                    } else {
                        ""
                    }
                    ValueLabel(label: "Source", value: uniqueIDValue)
                        .padding(.vertical)
                        .background(Color.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 16.0))
                }
            }
            
            if entity.destinations.isEmpty {
                Text("No Destinations")
                    .font(.title3)
                    .foregroundStyle(Color.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical)
            } else {
                ForEach(entity.destinations) { destination in
                    let uniqueIDValue = if let uniqueID = destination.uniqueID {
                        String(describing: uniqueID)
                    } else {
                        ""
                    }
                    ValueLabel(label: "Destination", value: uniqueIDValue)
                        .padding(.vertical)
                        .background(Color.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 16.0))
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 16.0))
        .padding()
    }
}

// MARK: - Preview

#Preview {
    MIDIEntityRow(entity: MIDIEntityModel(name: "Foo", uniqueID: 1, protocol: 1, inEndpoint: 1, outEndpoint: 2, maxSystemExclusiveSpeed: 1, isCable: true, isEmbedded: false, sources: [], destinations: []))
}
