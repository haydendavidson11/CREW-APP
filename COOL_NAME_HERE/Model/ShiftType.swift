//
//  ShiftType.swift
//  ShiftType
//
//  Created by Hayden Davidson on 7/30/21.
//

import Foundation

enum ShiftType: String, CaseIterable {
    case morning = "Morning (8am-12pm)"
    case afternoon = "Afternoon (1pm-5pm)"
    case fullDay = "Full Day (8am-5pm)"
    case extendedDay = "Extended Day (8am-8pm)"
}
