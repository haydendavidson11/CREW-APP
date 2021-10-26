//
//  AvailableDays.swift
//  AvailableDays
//
//  Created by Hayden Davidson on 7/30/21.
//

import Foundation
import RealmSwift


class AvailableDays: EmbeddedObject, ObjectKeyIdentifiable, Comparable {
    
    @objc dynamic var _id = UUID().uuidString
    @objc dynamic var type: String = ""
    var dates = List<Date>()
    
    var typeState: ShiftType {
        get { return ShiftType(rawValue: type) ?? .fullDay }
        set { type = newValue.asString }
    }
    
    static func == (lhs: AvailableDays, rhs: AvailableDays) -> Bool {
        return lhs.typeState.rawValue == rhs.typeState.rawValue
    }
    
    static func < (lhs: AvailableDays, rhs: AvailableDays) -> Bool {
        return lhs.typeState.rawValue < rhs.typeState.rawValue
    }
}
