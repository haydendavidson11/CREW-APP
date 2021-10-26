//
//  UserPreferences.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 4/12/21.
//

import RealmSwift

@objcMembers class UserPreferences: EmbeddedObject, ObjectKeyIdentifiable {
    dynamic var displayName: String?
    dynamic var avatarImage: Photo?
    dynamic var firstName: String?
    dynamic var lastName: String?
    dynamic var bio: String?
    dynamic var phoneNumber: String?
    dynamic var shareContactInfo = false
    dynamic var address: Address?
    dynamic var timeSheet: TimeSheet?
    var availability = List<AvailableDays>()
    var schedule = List<Shift>()
    
}
