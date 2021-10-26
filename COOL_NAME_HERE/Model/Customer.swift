//
//  Customer.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 3/28/21.
//

import Foundation
import RealmSwift


class Client: Object {
    
    @objc dynamic var _id = ObjectId.generate()
    @objc dynamic var firstName: String = ""
    @objc dynamic var lastName: String = ""
    @objc dynamic var address: Address?
    @objc dynamic var email: String = ""
    @objc dynamic var phoneNumber: String = ""
    
    convenience init(firstName: String, lastName: String, address: Address, email: String, phoneNumber: String) {
        self.init()
        self.firstName = firstName
        self.lastName = lastName
        self.address = address
        self.email = email
        self.phoneNumber = phoneNumber
    }
    
    
//    static var example: Client {
//        return Customer(firstName: "hayden", lastName: "davidson", address: Address.example , email: "haydendavidson@me.com", phoneNumber: "813-716-3618")
//    }
    
}
