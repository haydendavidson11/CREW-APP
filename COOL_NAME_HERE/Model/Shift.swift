//
//  Shift.swift
//  Shift
//
//  Created by Hayden Davidson on 8/10/21.
//

import Foundation
import RealmSwift

class Shift: EmbeddedObject, ObjectKeyIdentifiable {
    
    @objc dynamic var _id = UUID().uuidString
    @objc dynamic var type: String = ""
    @objc dynamic var date: Date?
    @objc dynamic var startTime: Date?
    @objc dynamic var EndTime: Date?
    @objc dynamic var crewMember: String? //crewMemberID assigned to this swift
    @objc dynamic var complete = false
    
}
