//
//  ScheduleView.swift
//  ScheduleView
//
//  Created by Hayden Davidson on 8/11/21.
//

import SwiftUI
import RealmSwift

struct ScheduleView: View {
    @EnvironmentObject var state: AppState
    
    @State private var filter = ""
    @State private var schedule = [Shift]()
    
    
    
    var body: some View {
            VStack {
                List {
                    if state.user?.userPreferences?.schedule != nil && schedule.count > 0 {
                        ForEach(schedule) { shift in
                            ShiftView(shift: shift, vertical: false)
                        }
                    } else {
                        if filter.isEmpty && schedule.isEmpty {
                            Text("You have not been scheduled for any shifts")
                        } else  if schedule.isEmpty {
                            Text("You have no upcoming shifts scheduled at this time.")
                        }
                    }
                }
            }
            .onAppear(perform: initData)
            .onChange(of: filter, perform: { newValue in
                filterSchedule()
            })
            .navigationTitle("Schedule")
            .navigationBarItems(trailing: ShiftFilterButton(filter: $filter))
            .navigationBarTitleDisplayMode(.inline)
        
        
        
    }
    
    func initData() {
        guard let userSchedule = state.user?.userPreferences?.schedule else { return }
        for shift in userSchedule {
            schedule.append(shift)
        }
    }
    
    func filterSchedule() {
        let today = Date()
        var shifts = [Shift]()
        guard let userSchedule = state.user?.userPreferences?.schedule else { return }
       
        for shift in userSchedule {
            if let date = shift.date {
                if filter.isEmpty {
                        shifts.append(shift)
                } else {
                    if date > today {
                        shifts.append(shift)
                    }
                }
            }
        }
        schedule = shifts.sorted { lhs, rhs in
            guard let lDate = lhs.date else { return  false }
            guard let rDate = rhs.date else { return false }
            return lDate < rDate
        }
    }
}

struct ShiftFilterButton: View {
    @Binding var filter: String
    
    var body: some View {
        Image(systemName: "line.horizontal.3.decrease.circle")
            .foregroundColor(.brandPrimary)
            .contextMenu(ContextMenu(menuItems: {
                Button("All Shifts") {
                    filter = ""
                }
                Button("Upcoming Shifts") {
                    filter = "upcoming"
                }
                
            }))
    }
}


struct ShiftView: View {
    var shift: Shift
    
    var vertical: Bool
    
    var startTime: String {
        return shift.startTime?.formatted(date: .omitted, time: .shortened) ?? "N/A"
    }
    
    var endTime: String {
        return shift.EndTime?.formatted(date: .omitted, time: .shortened) ?? "N/A"
    }
    
    var monthString:  String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"
        return dateFormatter.string(from: shift.date ?? Date())
    }
    
    
    var dayOfMonth: String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: shift.date ?? Date())
        return "\(components.day!)"
    }
    
    var fullWeekDayName: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        return dateFormatter.string(from: shift.date ?? Date())
    }
    
    var numberedMonth: String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: shift.date ?? Date())
        return "\(components.month!)"
    }
    
    
    
    
    var body: some View {
        
        if vertical {
            
            VStack(spacing: 4) {
                VStack(alignment: .center) {
                    Text(fullWeekDayName)
                    Text("\(numberedMonth)/\(dayOfMonth)")
                }
                
                Divider()
                
                VStack {
                    Text("\(startTime)")
                        .font(.caption)
                        .minimumScaleFactor(0.75)
                    Text("\(endTime)")
                        .font(.caption)
                        .minimumScaleFactor(0.75)
                }
            }
            
        } else {
            HStack {
                VStack(alignment: .center) {
                    Text(fullWeekDayName)
                    Text("\(numberedMonth)/\(dayOfMonth)")
                }
                
                Divider()
                
                VStack {
                    Text("\(startTime) - \(endTime)")
                }
            }
        }
    }
}


struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleView()
    }
}
