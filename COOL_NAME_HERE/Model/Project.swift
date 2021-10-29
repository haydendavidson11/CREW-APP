//
//  Project.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 6/19/21.
//

import Foundation
import RealmSwift


@objcMembers class Project: Object, ObjectKeyIdentifiable {
    
    dynamic var _id = UUID().uuidString
    dynamic var partition = ""
    dynamic var name: String?
    dynamic var client = "" // Client _id
    dynamic var address: Address?
    dynamic var isActive: String?
    dynamic var category: String = "Needs Estimate"
    dynamic var startTime: Date? // TODO delete property
    dynamic var startDate: Date?
    dynamic var completionDate: Date?
    let estimatedTimeToComplete = RealmOptional<Int>()
    var materials = List<Material>()
    var activity = List<Event>()
    dynamic var assignedCrew: Crew? // remove from schema
    var crew = List<String>()
    var todo = List<TodoItem>()
    
    var categoryState: Category {
        get { return Category(rawValue: category) ?? .needsEstimate }
        set { category = newValue.asString }
    }
    
    override static func primaryKey() -> String? {
            return "_id"
        }
}

enum Category: String, CaseIterable {
    case archived = "Archived"
    case needsEstimate = "Needs Estimate"
    case estimatePending = "Estimate Pending"
    case toBeScheduled = "To Be Scheduled"
    case scheduled = "Scheduled"
    case complete = "Complete"
    
    var asString: String {
        self.rawValue
    }
}
