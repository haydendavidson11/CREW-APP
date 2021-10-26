//
//  Customer.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 3/28/21.
//

import Foundation
import RealmSwift


class Client: Object, ObjectKeyIdentifiable {
    
    @objc dynamic var _id = UUID().uuidString
    @objc dynamic var partition = ""
    @objc dynamic var firstName: String = ""
    @objc dynamic var lastName: String = ""
    @objc dynamic var email: String = ""
    @objc dynamic var phoneNumber: String = ""
    @objc dynamic var address: Address?
    @objc dynamic var category: String = "Needs Estimate"
    var jobs = List<Job>()
    var activity = List<Event>()
    
    var categoryState: Category {
        get { return Category(rawValue: category) ?? .needsEstimate }
        set { category = newValue.asString }
    }
    
    override static func primaryKey() -> String? {
            return "_id"
        }
    
    convenience init(firstName: String, lastName: String, address: Address, email: String, phoneNumber: String) {
        self.init()
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.address = address
    }
}
