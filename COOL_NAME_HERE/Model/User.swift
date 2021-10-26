//
//  Login.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 3/28/21.
//

import Foundation
import SwiftUI
import RealmSwift


class User: Object, ObjectKeyIdentifiable {
    
    @objc dynamic var _id = UUID().uuidString
    @objc dynamic var partition = ""
    @objc dynamic var userName: String = ""
    @objc dynamic var userPreferences: UserPreferences?
    @objc dynamic var companyID: String?
    @objc dynamic var role: String?
    @objc dynamic var deviceToken: String?
    
    
    override static func primaryKey() -> String? {
            return "_id"
        }
}
