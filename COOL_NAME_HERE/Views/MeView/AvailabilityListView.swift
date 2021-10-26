//
//  ScheduleView.swift
//  ScheduleView
//
//  Created by Hayden Davidson on 8/6/21.
//

import SwiftUI
import RealmSwift



struct AvailabilityListView: View {
    @EnvironmentObject var state: AppState
    @EnvironmentObject var monthModel: MDPModel
    @Environment(\.calendar) var calendar
    
    @State var numDays = 0
    @State var title = ""
    
    var weekDays: [Date] {
        
        let year = calendar.component(.year, from: monthModel.controlDate)
        let month = calendar.component(.month, from: monthModel.controlDate)
        
        let dateComponents = DateComponents(year: year, month: month)
        let date = calendar.date(from: dateComponents)!
        
        let range = calendar.range(of: .day, in: .month, for: date)!
        let numDays = range.count
        
        
        var index = 0
        
        var daysArray = [Date]()
        
        
        for i in 0..<numDays {
            let realDate = calendar.date(from: DateComponents(year: year, month: month, day: i+1))
            
            
            
            daysArray.append(realDate ?? Date())
            index += 1
        }
        return daysArray
    }
    
    let formatter = DateFormatter()
    
    var body: some View {
        
        List(0..<weekDays.count, id: \.self) { index in
            HStack {
                VStack(alignment: .center, spacing: 3) {
                    Text(getFullWeekDayName(date: weekDays[index]))
                        .font(.footnote)
                    Text(getDayOfMonth(date:weekDays[index]))
                        .bold()
                }
                .frame(width: 40)
                .foregroundColor(calendar.isDateInToday(weekDays[index]) ? .brandPrimary : .primary)
                Text(getDayShift(date: weekDays[index]))
            }
        }
    }
    
    func getShortDate(date: Date) -> String {
        formatter.dateStyle = .short
  
        let dateString = formatter.string(from: date)
        return dateString
    }
    
    func getNumberedMonth(date: Date) -> Int {
        //
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: date)
        return components.month ?? 0
        
    }
    
    func getYearString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: date)
    }
    
    func getMonthString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"
        return dateFormatter.string(from: date)
    }
    
    func getFullWeekDayName(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        return dateFormatter.string(from: date)
    }
    
    func getDayOfMonth(date: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: date)
        return "\(components.day!)"
    }
    
    func getDayShift(date: Date) -> String {
        var str = "Not Available"
 
        if monthModel.mornings.dates.contains(date) {
            str = "Available for morning shift"
        }
        if monthModel.afternoons.dates.contains(date) {
            str = "Available for afternoon shift"
        }
        
        if monthModel.fullDays.dates.contains(date) {
            str = "Available All Day"
        }
        
        return str
    }
}

//struct ScheduleView_Previews: PreviewProvider {
//    static var previews: some View {
//        ScheduleView()
//    }
//}
