//
//  Request.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 7/13/21.
//

import Foundation
import RealmSwift

class Request: Object, ObjectKeyIdentifiable {
    
    @objc dynamic var _id = UUID().uuidString
    @objc dynamic var partition = "public=public"
    @objc dynamic var type: String = ""
    @objc dynamic var crewMember: String? // crewMember ID
    @objc dynamic var company: String? // company ID
    @objc dynamic var sender: String?
    @objc dynamic var recipient: String?
    @objc dynamic var status: String = ""
    @objc dynamic var requestDescription = ""
    @objc dynamic var dateCreated = Date()
    @objc dynamic var role: String?
    @objc dynamic var shift: Shift?
    
    
    var typeState: RequestType {
        get { return RequestType(rawValue: type) ?? .invite }
        set { type = newValue.asString }
    }
    
    
    var requestState: RequestStatus {
        get { return RequestStatus(rawValue: status) ?? .pending }
        set { status = newValue.asString }
    }
    
    override static func primaryKey() -> String? {
            return "_id"
        }
}


enum RequestType: String {
    case invite = "invite" // from company to crewMember
    case join = "join" // from crewMember to company
    case shift = "shift"
    case roleChange = "roleChange"
    
    
    var asString: String {
        self.rawValue
    }
}

enum RequestStatus: String {
    case pending = "pending"
    case accepted = "accepted"
    case denied = "denied"
    
    var asString: String {
        self.rawValue
    }
}
