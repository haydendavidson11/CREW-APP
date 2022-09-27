//
//  CalendarHelper.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 10/2/21.
//

import Foundation
import EventKit
import EventKitUI

class CalendarHelper: ObservableObject {
    let eventStore: EKEventStore = EKEventStore()
    
    var havePermission = false
          
    // 'EKEntityTypeReminder' or 'EKEntityTypeEvent'
    func requestPermission() {
        eventStore.requestAccess(to: .event) { (granted, error) in
          
          if (granted) && (error == nil) {
              self.havePermission = true
              
          }
          else{
              print("failed to save event with error : \(error) or access not granted")
          }
        }
    }
    
    func createEvent(from request: Request) -> EKEvent {
        let event:EKEvent = EKEvent(eventStore: self.eventStore)
        
        event.title = "New Shift"
        event.startDate = request.shift?.startTime
        event.endDate = request.shift?.EndTime
        event.notes = ""
        event.calendar = self.eventStore.defaultCalendarForNewEvents
//        do {
//            try self.eventStore.save(event, span: .thisEvent)
//        } catch let error as NSError {
//            print("failed to save event with error : \(error)")
//        }
//        print("Saved Event")
        return event
    }
}
