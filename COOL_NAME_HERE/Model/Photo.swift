//
//  Photo.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 4/12/21.
//

import RealmSwift
import SwiftUI

@objcMembers class Photo: EmbeddedObject, ObjectKeyIdentifiable {
    dynamic var _id = UUID().uuidString
    dynamic var thumbNail: Data?
    dynamic var picture: Data?
    dynamic var date = Date()
}
