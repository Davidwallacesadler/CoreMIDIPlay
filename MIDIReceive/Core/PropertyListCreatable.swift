//
//  PropertyListCreatable.swift
//  MIDIReceive
//
//  Created by David Sadler on 6/16/24.
//

import Foundation

protocol PropertyListCreatable {
    static func from(propertyList propList: CFPropertyList?) -> Self?
}
