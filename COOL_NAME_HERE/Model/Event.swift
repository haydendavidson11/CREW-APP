//
//  Event.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 5/5/21.
//

import Foundation
import RealmSwift

class Event: EmbeddedObject, Identifiable {
    
    let id = UUID().uuidString
    @objc dynamic var type: String = ""
    @objc dynamic var info: String?
    @objc dynamic var date: String?
    @objc dynamic var userAvatar: Photo?
    @objc dynamic var image: Photo?
    
    var typeState: Activity {
        get { return Activity(rawValue: type) ?? .comment }
        set { type = newValue.asString }
    }
}

enum Activity: String {
    case comment = "New Comment"
    case categoryChanged = "Category Changed"
    case contactInfoUpdated = "Contact Info Updated"
    case jobCreated = "Job Created"
    case crewMemberAdded = "Crew Member Added"
    case crewMemberRemoved = "Crew Member Removed"
    
    var asString: String {
        self.rawValue
    }
}
