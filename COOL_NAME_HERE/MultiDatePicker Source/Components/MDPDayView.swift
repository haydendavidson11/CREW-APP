//
//  DayOfMonthView.swift
//  MultiDatePickerApp
//
//  Created by Peter Ent on 11/2/20.
//

import SwiftUI

struct MDPDayView: View {
    @EnvironmentObject var state : AppState
    @EnvironmentObject var monthDataModel: MDPModel
    @Environment(\.calendar) var calendar
    let cellSize: CGFloat = 35
    var dayOfMonth: MDPDayOfMonth
    
    // outline "today"
    private var strokeColor: Color {
        dayOfMonth.isToday ? Color.accentColor : Color.clear
    }
    
    @State private var shiftColor: Color?
    
    @State private var existingDate = false
    
    var selectedShift: Color {
        var color = Color.clear
        switch monthDataModel.shiftType {
        case .morning : color = .halfDayAM
        case .afternoon: color = .halfDayPM
        case .fullDay: color = .fullDay
        default: color = .black
            print("shift type was not set when DOM selected")
        }
        
        return color
    }
    
    
    
    // filled if selected
    private var fillColor: Color {
//        monthDataModel.isSelected(dayOfMonth) && shiftColor != nil ? shiftColor! : Color.clear
//        shiftColor != nil ? shiftColor! : Color.clear
        guard let date = dayOfMonth.date else { return Color.clear }
        if monthDataModel.fullDays.dates.contains(date) && monthDataModel.selections.contains(date) {
            return .fullDay
//            shiftColor = .fullDay
        }

        if monthDataModel.mornings.dates.contains(date) && monthDataModel.selections.contains(date) {
            return Color("halfDayAM")
        }

        if monthDataModel.afternoons.dates.contains(date) && monthDataModel.selections.contains(date) {
            return Color("halfDayPM")
        }
        
        guard let schedule = state.user?.userPreferences?.schedule else { return .clear }
        print("have schedule")
        for shift in schedule {
            guard let shiftDate = shift.date else {return .clear }
            print("have shift date \(shiftDate)")
            guard let calendarDay = dayOfMonth.date else { return .clear}
            print("have day of the month date \(calendarDay)")
            if calendar.isDate(shiftDate, inSameDayAs: calendarDay) {
                print("dates are the same. setting shift color.")
                return .gray.opacity(0.4)
            }
            
        }
    
        
        return Color.clear

    }
    
    private var isScheduled: Bool {
        guard let schedule = state.user?.userPreferences?.schedule else { return false }
        print("have schedule")
        for shift in schedule {
            guard let shiftDate = shift.date else {return false}
            print("have shift date \(shiftDate)")
            guard let calendarDay = dayOfMonth.date else { return false}
            print("have day of the month date \(calendarDay)")
            if calendar.isDate(shiftDate, inSameDayAs: calendarDay) {
                print("dates are the same. setting shift color.")
                return true
            }
            
        }
        return false
    }
    
    // reverse color for selections or gray if not selectable
    private var textColor: Color {
        if dayOfMonth.isSelectable {
            return monthDataModel.isSelected(dayOfMonth) ? Color.white : Color.black
        } else {
            return Color.gray
        }
    }
    
    private func handleSelection() {
        print(existingDate)
        if dayOfMonth.isSelectable {
            monthDataModel.selectDay(dayOfMonth, existingDay: existingDate)
            shiftColor = selectedShift
            existingDate = false
//            initData()
            
        }
    }
    
    var body: some View {
        Button( action: { handleSelection()} ) {
            Text("\(dayOfMonth.day)")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(textColor)
                .frame(minHeight: cellSize, maxHeight: cellSize)
                .background(
                    Circle()
                        .stroke(strokeColor, lineWidth: 1)
                        .background(Circle().foregroundColor(fillColor))
                        .frame(width: cellSize, height: cellSize)
                )
        }.foregroundColor(.black)
            .disabled(isScheduled)
    }
    
    
}

//struct DayOfMonthView_Previews: PreviewProvider {
//    static var previews: some View {
//        MDPDayView(dayOfMonth: MDPDayOfMonth(index: 0, day: 1, date: Date(), isSelectable: true, isToday: false))
//            .environmentObject(MDPModel())
//    }
//}
