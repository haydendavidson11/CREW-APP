//
//  Role.swift
//  Role
//
//  Created by Hayden Davidson on 8/10/21.
//

import Foundation

enum Role: String, CaseIterable {
    case admin = "Admin"
    case manager = "Manager"
    case member = "Member"
    
    var asString: String {
        self.rawValue
    }
}
