//
//  TodoItem.swift
//  TodoItem
//
//  Created by Hayden Davidson on 9/21/21.
//

import Foundation
import RealmSwift


class TodoItem: EmbeddedObject, ObjectKeyIdentifiable {
    
    @objc dynamic var _id = UUID().uuidString
    @objc dynamic var name: String = ""
    @objc dynamic var dateCreated: Date?
    @objc dynamic var completionDate: Date?
    @objc dynamic var crewMember: String? //crewMemberID that completed this todo item
    @objc dynamic var complete = false
    var needed = RealmOptional<Int>()
    var onHand = RealmOptional<Int>()
    
}
