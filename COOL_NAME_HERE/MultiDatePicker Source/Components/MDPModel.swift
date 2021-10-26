//
//  MonthDataModel.swift
//  MultiDatePickerApp
//
//  Created by Peter Ent on 11/2/20.
//

import SwiftUI
import Combine
import RealmSwift
import Network
/**
 * This model is used internally by the MultiDatePicker to coordinate what is displayed and what
 * is selected.
 *
 * When the controlDate is set, an array of MDPDayOfMonth objects are created, each representing
 * a day of the controlDate's month/year.
 *
 * The type of selection (single, allDays, dateRange) is determined by which init() method is used
 * for the model.
 *
 * The MDPModel should not be used outside of the MultiDatePicker, which initalizes this model
 * according to the type of selection required.
 */

class MDPModel: NSObject, ObservableObject {
    
    // the controlDate determines which month/year is being modeled. whenever it changes it
    // triggers a refresh of the days collection.
    public var controlDate: Date = Date() {
        didSet {
            buildDays()
//            initData()
        }
    }
    
    // this collection is created whenever the controlDate is changed and reflects the
    // days of the month for the controlDate's month/year
    @Published var days = [MDPDayOfMonth]() {
        didSet {
            for day in days {
                if day.dayColor != nil {
                    print(day)
                }
            }
        }
    }
    
    
    // once a controlDate is established, this value will be the formatted Month Year (localized)
    @Published var title = ""
    
    // this array maintains the selections. for a single date it is an array of 1. for many
    // dates it is an array of those dates. for a date range, it is an array of 2.
    @Published var selections = [Date]()
    
    @Published var fullDays = AvailableDays() {
        didSet {
            print("FullDays Changed")
        }
    }
    
    @Published var mornings = AvailableDays()
    
    @Published var afternoons = AvailableDays()
    @Published var schedule = [Date]()
    
    
    
    
    @Published var shiftType: ShiftType? {
        didSet {
            print("set published shift type to \(shiftType)")
           
        }
    }
    
    
    var user: User? {
        didSet {
            print(user)
//            initData()
        }
    }
    
    
    // the localized days of the week
    let dayNames = Calendar.current.shortWeekdaySymbols
    
    // MARK: - PRIVATE VARS
    
    // holds the bindings from the app and get updated as the selection changes
    var singleDayWrapper: Binding<Date>?
    var anyDatesWrapper: Binding<[Date]>?
    var dateRangeWrapper: Binding<ClosedRange<Date>?>?
    var shiftTypeWrapper: Binding<ShiftType>?
    
    var fullDaysWrapper: Binding<AvailableDays>? {
        didSet {
//            buildDays()
//            initData()
        }
    }
    var morningsWrapper: Binding<AvailableDays>? {
        didSet {
//            buildDays()
//            initData()
        }
    }
    var afternoonsWrapper: Binding<AvailableDays>? {
        didSet {
//            buildDays()
//            initData()
        }
    }
    
    
    // the type of date picker
    private var pickerType: MultiDatePicker.PickerType = .anyDays
    
    // which days are available for selection
    private var selectionType: MultiDatePicker.DateSelectionChoices = .allDays
    
    // the actual number of days in this calendar month/year (eg, 28 for February)
    private var numDays = 0
    
    
    
    
    
    // MARK: - INIT
    
    convenience init(anyDays: Binding<[Date]>, mornings: Binding<AvailableDays>, afternoons: Binding<AvailableDays>, fullDays: Binding<AvailableDays>, shiftType: Binding<ShiftType>) {
        
        print("INITIALIZING")
        self.init()
        self.anyDatesWrapper = anyDays
        self.shiftTypeWrapper = shiftType
//        initData()
        
        setSelection(anyDays.wrappedValue, mornings: mornings.wrappedValue, afternoons: afternoons.wrappedValue, fullDays: fullDays.wrappedValue, shift: shiftType.wrappedValue)
        
        
        
        
        
        
        // set the controlDate to be the first of the anyDays if the
        // anyDays array is not empty.
        if let useDate = anyDays.wrappedValue.first {
            controlDate = useDate
        }
        
        buildDays()
    }
    
    
    
    // MARK: - PUBLIC
    
    
    func dayOfMonth(byDay: Int) -> MDPDayOfMonth? {
        guard 1 <= byDay && byDay <= 31 else { return nil }
        for dom in days {
            if dom.day == byDay {
                return dom
            }
        }
        return nil
    }
    
    // refactored addition of MDPDayOfTheMonth to selections here
    func addOrRemoveOnSelection(date: Date?, existingDay: Bool) {
        guard let date = date else { return }
        
        if existingDay {
//            selections.append(date)
            if selections.contains(date), let pos = selections.firstIndex(of: date) {
                selections.remove(at: pos)
            }
            print(date)
            print(selections.count)
            print(selections.count)
            switch shiftType {
            case .fullDay:
//                if !fullDays.dates.contains(date) {
//                    fullDays.dates.append(date)
//                }
                if  fullDays.dates.contains(date), let pos = fullDays.dates.firstIndex(of: date) {
                    fullDays.dates.remove(at: pos)
                }
            case .morning :
//                if !mornings.dates.contains(date) {
//                    mornings.dates.append(date)
//                }
                if mornings.dates.contains(date), let pos = mornings.dates.firstIndex(of: date) {
                    mornings.dates.remove(at: pos)
                }
            case .afternoon:
//                if !afternoons.dates.contains(date) {
//                    afternoons.dates.append(date)
//                }
                if afternoons.dates.contains(date), let pos = afternoons.dates.firstIndex(of: date) {
                    afternoons.dates.remove(at: pos)
                }
            default: print("shift type not set ")
            }
            
        } else {
            
            shiftType = shiftTypeWrapper?.wrappedValue
            
            if selections.contains(date), let pos = selections.firstIndex(of: date) {
                selections.remove(at: pos)
            } else {
                selections.append(date)
            }
            
            var allAvailableDays = [Date]()
            
            for date in mornings.dates {
                allAvailableDays.append(date)
            }
            for date in afternoons.dates {
                allAvailableDays.append(date)
            }
            for date in fullDays.dates {
                allAvailableDays.append(date)
            }
            
            
            if allAvailableDays.contains(date) {
                
                if fullDays.dates.contains(date), let pos = fullDays.dates.firstIndex(of: date) {
                    fullDays.dates.remove(at: pos)
                }
                
                
                if mornings.dates.contains(date), let pos = mornings.dates.firstIndex(of: date) {
                    mornings.dates.remove(at: pos)
                }
                
                if afternoons.dates.contains(date), let pos = afternoons.dates.firstIndex(of: date) {
                    afternoons.dates.remove(at: pos)
                }
                
            } else {
                switch shiftType {
                case .fullDay:
                    if fullDays.dates.contains(date), let pos = fullDays.dates.firstIndex(of: date) {
                        fullDays.dates.remove(at: pos)
                    } else {
                        fullDays.dates.append(date)
                    }
                case .morning :
                    if mornings.dates.contains(date), let pos = mornings.dates.firstIndex(of: date) {
                        mornings.dates.remove(at: pos)
                    } else {
                        mornings.dates.append(date)
                    }
                case .afternoon:
                    if afternoons.dates.contains(date), let pos = afternoons.dates.firstIndex(of: date) {
                        afternoons.dates.remove(at: pos)
                    } else {
                        afternoons.dates.append(date)
                    }
                default: print("shift type not set ")
                }
            }
        }
        
        morningsWrapper?.wrappedValue = mornings
        afternoonsWrapper?.wrappedValue = afternoons
        fullDaysWrapper?.wrappedValue = fullDays
//        buildDays()
    }
    
    func selectDay(_ day: MDPDayOfMonth, existingDay: Bool) {
        guard day.isSelectable else { return }
        guard let date = day.date else { return }
        
        addOrRemoveOnSelection(date: date, existingDay: existingDay)
        
    }
    
    func isSelected(_ day: MDPDayOfMonth) -> Bool {
//        guard day.isSelectable else { return false }
        guard let date = day.date else { return false }
//
//        if pickerType == .anyDays || pickerType == .singleDay {
//            for test in selections {
//                if isSameDay(date1: test, date2: date) || day.dayColor != nil {
//                    return true
//                }
//            }
//        }
        if fullDays.dates.contains(date) && selections.contains(date) {
            return true
//            shiftColor = .fullDay
        }

        if mornings.dates.contains(date) && selections.contains(date) {
            return true
        }

        if afternoons.dates.contains(date) && selections.contains(date) {
            return true
        }
        return false
    }
    
    func incrMonth() {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .month, value: 1, to: controlDate) {
            print("Increasing month")
            controlDate = newDate
        }
    }
    
    func decrMonth() {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .month, value: -1, to: controlDate) {
            print("decreasing month")
            controlDate = newDate
        }
    }
    
    func show(month: Int, year: Int) {
        let calendar = Calendar.current
        let components = DateComponents(year: year, month: month, day: 1)
        if let newDate = calendar.date(from: components) {
            controlDate = newDate
        }
    }
    
    func initData() {
//        guard let date = controlDate else { return }
//        if monthDataModel.fullDays.dates.contains(date) {
//            shiftColor = .fullDay
//        }
//
//        if monthDataModel.mornings.dates.contains(date) {
//            shiftColor = .halfDayAM
//        }
//
//        if monthDataModel.afternoons.dates.contains(date) {
//            shiftColor = .halfDayPM
//        }
        
        guard let availability = user?.userPreferences?.availability else {
            print("no user availability")
            return
        }
        print("have availability")
        if availability.count > 0 {
            if let morningShifts = availability.filter(NSPredicate(format: "type == %@", "Morning")).first {
                print("morning dates \(morningShifts.dates.count)")
                for date in morningShifts.dates {
//                    if !mornings.dates.contains(date) {
//                        mornings.dates.append(date)
//                    }
                    var dom = MDPDayOfMonth()
                    dom.date = date
                    selectDay(dom, existingDay: true)
                }
            }
            
            if let afternoonShifts = availability.filter(NSPredicate(format: "type == %@", "Afternoon")).first {
                print("afternoons \(afternoonShifts.dates.count)")
                for date in afternoonShifts.dates {
//                    if !afternoons.dates.contains(date) {
//                        afternoons.dates.append(date)
//                    }
                    var dom = MDPDayOfMonth()
                    dom.date = date
                    selectDay(dom, existingDay: true)
                }
            }
            
            
            if let fullDayShifts = availability.filter(NSPredicate(format: "type == %@", "FullDay")).first {
                print("full days \(fullDayShifts.dates.count)")
                for date in fullDayShifts.dates {
//                    if !fullDays.dates.contains(date) {
//                        fullDays.dates.append(date)
//                    }
                    var dom = MDPDayOfMonth()
                    dom.date = date
                    selectDay(dom, existingDay: true)
                }
            }
        }
    }
    
}

// MARK: - BUILD DAYS

extension MDPModel {
    
    func buildDays() {
        print("Building Days")
        print("\(selections.count) selections")
        print("\(mornings.dates.count) mornings")
        print("\(afternoons.dates.count) afternoons")
        print("\(fullDays.dates.count) fullDays")
        
        print("initializing data")
//        initData()
        
        print("\(selections.count) selections")
        print("\(mornings.dates.count) mornings")
        print("\(afternoons.dates.count) afternoons")
        print("\(fullDays.dates.count) fullDays")
        let calendar = Calendar.current
        let year = calendar.component(.year, from: controlDate)
        let month = calendar.component(.month, from: controlDate)
        
        let dateComponents = DateComponents(year: year, month: month)
        let date = calendar.date(from: dateComponents)!
        
        let range = calendar.range(of: .day, in: .month, for: date)!
        let numDays = range.count
        
        let ord = calendar.component(.weekday, from: date)
        var index = 0
        
        
        
        let today = Date()
        
        // create an empty int array
        var daysArray = [MDPDayOfMonth]()
        
        // for 0 to ord, set the value in the array[index] to be 0, meaning no day here.
        for _ in 1..<ord {
            daysArray.append(MDPDayOfMonth(index: index, day: 0))
            index += 1
        }
        
        // for index in range, create a DayOfMonth that will represent one of the days
        // in the month. This object needs to be told if it is eligible for selection
        // which is based on the selectionType and min/max dates if present.
        for i in 0..<numDays {
            let realDate = calendar.date(from: DateComponents(year: year, month: month, day: i+1))
            var dom = MDPDayOfMonth(index: index, day: i+1, date: realDate)
            dom.isToday = isSameDay(date1: today, date2: realDate)
            dom.isSelectable = isEligible(date: realDate)
            
            if let date = dom.date {
                if fullDays.dates.contains(date) {
                    dom.dayColor = Color("fullDay")
//                    dom.isSelected = true
                }
                if afternoons.dates.contains(date) {
                    dom.dayColor = Color("halfDayPM")
//                    dom.isSelected = true
                }
                if mornings.dates.contains(date) {
                    dom.dayColor = Color("halfDayPM")
//                    dom.isSelected = true
                }
            }
            
            daysArray.append(dom)
            index += 1
        }
        
        // if index is not a multiple of 7, then append 0 to array until the next 7 multiple.
        let total = daysArray.count
        var remainder = 42 - total
        if remainder < 0 {
            remainder = 42 - total
        }
        
        for _ in 0..<remainder {
            daysArray.append(MDPDayOfMonth(index: index, day: 0))
            index += 1
        }
        
        self.numDays = numDays
        self.title = "\(calendar.monthSymbols[month-1]) \(year)"
        self.days = daysArray
        
        
        //ADDED TO DEBUG
//        if user != nil {
//            for availability in user!.userPreferences!.availability {
//                for date in availability.dates {
//                    addOrRemoveOnSelection(date: date, existingDay: true)
//                }
//            }
//        }
       
        
    }
}

// MARK: - UTILITIES

extension MDPModel {
    
    
    private func setSelection(_ anyDates: [Date], mornings: AvailableDays, afternoons: AvailableDays, fullDays: AvailableDays, shift: ShiftType) {
        pickerType = .anyDays
        shiftType = shift
        print("set selection \(String(describing: shiftType))")
    }
    
    
    func isSameDay(date1: Date?, date2: Date?) -> Bool {
        guard let date1 = date1, let date2 = date2 else { return false }
        let day1 = Calendar.current.component(.day, from: date1)
        let day2 = Calendar.current.component(.day, from: date2)
        let year1 = Calendar.current.component(.year, from: date1)
        let year2 = Calendar.current.component(.year, from: date2)
        let month1 = Calendar.current.component(.month, from: date1)
        let month2 = Calendar.current.component(.month, from: date2)
        return (day1 == day2) && (month1 == month2) && (year1 == year2)
    }
    
    private func isEligible(date: Date?) -> Bool {
        guard let date = date else { return true }
        
        switch selectionType {
        case .weekendsOnly:
            let ord = Calendar.current.component(.weekday, from: date)
            return ord == 1 || ord == 7
        case .weekdaysOnly:
            let ord = Calendar.current.component(.weekday, from: date)
            return 1 < ord && ord < 7
        default:
            return true
        }
    }
}


