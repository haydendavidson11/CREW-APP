//
//  ShiftType.swift
//  ShiftType
//
//  Created by Hayden Davidson on 7/31/21.
//

import Foundation

enum ShiftType: String, CaseIterable {
    case morning = "Morning"
    case afternoon = "Afternoon"
    case fullDay = "FullDay"

    var asString: String {
        self.rawValue
    }
    
}
