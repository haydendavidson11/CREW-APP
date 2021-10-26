//
//  CrewMember.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 3/27/21.
//

import Foundation
import RealmSwift


class CrewMember: Object, ObjectKeyIdentifiable {
    
    @objc dynamic var _id = UUID().uuidString
    @objc dynamic var partition = "public=public"
    let experience = RealmOptional<Int>()
    @objc dynamic var role: String?
    @objc dynamic var displayName: String?
    @objc dynamic var userName: String?
    @objc dynamic var email: String?
    @objc dynamic var phone: String?
    @objc dynamic var address: Address?
    @objc dynamic var bio: String?
    @objc dynamic var avatarImage: Photo?
    @objc dynamic var companyID: String?
    var shareContactInfo = RealmOptional<Bool>()
    var availability = List<AvailableDays>()
    var schedule = List<Shift>()
    
    
    override static func primaryKey() -> String? {
            return "_id"
        }
}
