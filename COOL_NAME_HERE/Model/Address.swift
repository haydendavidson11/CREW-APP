//
//  Address.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 3/28/21.
//

import Foundation
import RealmSwift


class Address: EmbeddedObject, ObjectKeyIdentifiable{
    
    @objc dynamic var street: String?
    @objc dynamic var city: String?
    @objc dynamic var zip: String?
    @objc dynamic var state: String?
    @objc dynamic var country: String?
    @objc dynamic var gateCode: String?
}


