//
//  Crew.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 3/27/21.
//

import Foundation
import RealmSwift


class Crew: EmbeddedObject {
    @objc dynamic var name: String?
    var members = List<String>() // CrewMember IDs
}
