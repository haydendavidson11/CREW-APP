//
//  Job.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 3/27/21.
//

import Foundation
import RealmSwift


// TODO remove job from client schema and

class Job: EmbeddedObject, ObjectKeyIdentifiable {
    
    @objc dynamic var _id = UUID().uuidString
    @objc dynamic var isActive: String?
    @objc dynamic var startTime: Date?
    @objc dynamic var startDate: Date?
    @objc dynamic var completionDate: Date?
    let estimatedTimeToComplete = RealmOptional<Int>()
    var materials = List<Material>()
    @objc dynamic var assignedCrew: Crew?
    let comments = List<Comment>() // TODO delete property
}
