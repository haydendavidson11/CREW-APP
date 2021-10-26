//
//  Company.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 6/15/21.
//

import Foundation
import RealmSwift

class Company: Object, ObjectKeyIdentifiable {
    
    @objc dynamic var _id = UUID().uuidString
    @objc dynamic var avatarImage: Photo?
    @objc dynamic var partition = "public=public" 
    @objc dynamic var companyName = ""
    @objc dynamic var companyDescription = ""
    @objc dynamic var foundedDate: String?
    @objc dynamic var address: Address?
    @objc dynamic var phoneNumber: String?
    @objc dynamic var founder: String?
    var members = List<String>()
    var admins = List<String>()
    var managers = List<String>()
    var jobs = List<Job>()
    var schedule = List<Shift>()
    var materials = List<Material>()
    var crews = List<Crew>()
    
     override static func primaryKey() -> String? {
             return "_id"
         }
     
    func isAdmin(userID: String) -> Bool {
        return admins.contains(userID)
    }
    
    func isManager(userID: String) -> Bool {
        return managers.contains(userID)
    }

}
