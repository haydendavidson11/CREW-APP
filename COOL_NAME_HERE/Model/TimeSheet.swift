//
//  TimeSheet.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 3/28/21.
//

import Foundation
import RealmSwift


class TimeSheet: EmbeddedObject {
    
    @objc dynamic var date: Date?
    let hoursWorked = RealmOptional<Double>()
    let paidYTD = RealmOptional<Double>()
    let owed = RealmOptional<Double>()
    let paidInFull = RealmOptional<Bool>()
    
    convenience init(date: Date, hoursWorked: Double, paidYTD: Double, owed: Double, paidInFull: Bool) {
        self.init()
        self.date = date
        self.hoursWorked.value = hoursWorked
        self.paidYTD.value = paidYTD
        self.owed.value = owed
        self.paidInFull.value = paidInFull
    }
}
