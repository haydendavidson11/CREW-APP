//
//  File.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 3/28/21.
//

import Foundation
import RealmSwift

class Material: EmbeddedObject {
    
    @objc dynamic var SKU: String?
    @objc dynamic var photo: Photo?
    @objc dynamic var type: String?
    @objc dynamic var itemDescription: String?
    var price = RealmOptional<Double>()
    var quantity = RealmOptional<Double>()
    
    convenience init(type: String, itemDescription: String, quantity: Double){
        self.init()
        self.type = type
        self.itemDescription = itemDescription
        self.quantity.value = quantity
    }
}
