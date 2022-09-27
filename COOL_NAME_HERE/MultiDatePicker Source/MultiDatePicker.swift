//
//  MultiDatePicker.swift
//  MultiDatePickerApp
//
//  Created by Hayden Davidson.
//

import SwiftUI
import RealmSwift


struct MultiDatePicker: View {
    @EnvironmentObject var state: AppState
    @Environment(\.realm) var userRealm
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject var monthModel: MDPModel
//    @StateObject var monthModel = MDPModel()
    @State private var didChangeAvailability = false
    
    
   

    
    //     the type of picker, based on which init() function is used.
    enum PickerType {
        case singleDay
        case anyDays
        case dateRange
    }

    //    // lets all or some dates be eligible for selection.
    enum DateSelectionChoices {
        case allDays
        case weekendsOnly
        case weekdaysOnly
    }
    
    
    init(anyDays: Binding<[Date]>, mornings: Binding<AvailableDays>, afternoons: Binding<AvailableDays>, fullDays: Binding<AvailableDays>, shiftType: Binding<ShiftType>

    ) {

        _monthModel = StateObject(wrappedValue: MDPModel(anyDays: anyDays, mornings: mornings, afternoons: afternoons, fullDays: fullDays, shiftType: shiftType))

    }
    
    
    var body: some View {
        
        VStack {
            MDPMonthView()
            HStack {
                VStack {
                    ZStack {
                        Circle()
                            .foregroundColor(.gray.opacity(0.6))
                            .frame(width: 30)
                        if state.user?.userPreferences?.schedule != nil {
                            Text(state.user!.userPreferences!.schedule.count > 0   ? "\(state.user!.userPreferences!.schedule.count)" : "")
                                .foregroundColor(.white)
                        }
                    }
                    Text("Scheduled")
                        .font(.caption)
                }
                Spacer()
                VStack {
                    ZStack {
                        Circle()
                            .foregroundColor(.halfDayAM)
                            .frame(width: 30)
                        Text(monthModel.mornings.dates.count > 0  ? "\(monthModel.mornings.dates.count)" : "")
                            .foregroundColor(.white)
                    }
                    Text("Morning")
                        .font(.caption)
                }
                Spacer()
                VStack {
                    ZStack {
                        Circle()
                            .foregroundColor(.halfDayPM)
                            .frame(width: 30)
                        Text(monthModel.afternoons.dates.count > 0  ? "\(monthModel.afternoons.dates.count)" : "")
                            .foregroundColor(.white)
                    }
                    Text("Afternoon")
                        .font(.caption)
                }
                Spacer()
                VStack {
                    ZStack {
                        Circle()
                            .foregroundColor(.fullDay)
                            .frame(width: 30)
                        Text(monthModel.fullDays.dates.count > 0  ? "\(monthModel.fullDays.dates.count)" : "")
                            .foregroundColor(.white)
                    }
                    Text("Full Day")
                        .font(.caption)
                }
            }
            .frame(width: 300, height: 40)
            Divider()
                .padding(.horizontal)
            
            AvailabilityListView()
                .environmentObject(monthModel)
                .padding(.bottom)
        }
        .navigationBarBackButtonHidden(true)
        .environmentObject(monthModel)
        .environmentObject(state)
        .navigationBarItems(leading: Button(action: {
            saveAvailability()
            self.presentationMode.wrappedValue.dismiss()
        }, label:  {BackButton()}))
        .onAppear {
            initData()
        }
    }
    
    func initData() {
        
        guard let availability = state.user?.userPreferences?.availability else {
            print("no user availability")
            return
        }
        print("have availability")
        if availability.count > 0 {
            if let morningShifts = availability.filter(NSPredicate(format: "type == %@", "Morning")).first {
                print("morning dates \(morningShifts.dates.count)")
                for date in morningShifts.dates {
                    if !monthModel.mornings.dates.contains(date) {
                        monthModel.mornings.dates.append(date)
                    }
                    if !monthModel.selections.contains(date) {
                        monthModel.selections.append(date)
                    }
                }
            }
            
            if let afternoonShifts = availability.filter(NSPredicate(format: "type == %@", "Afternoon")).first {
                print("afternoons \(afternoonShifts.dates.count)")
                for date in afternoonShifts.dates {
                    if !monthModel.afternoons.dates.contains(date) {
                        monthModel.afternoons.dates.append(date)
                    }
                    if !monthModel.selections.contains(date) {
                        monthModel.selections.append(date)
                    }
                }
            }
            
            
            if let fullDayShifts = availability.filter(NSPredicate(format: "type == %@", "FullDay")).first {
                print("full days \(fullDayShifts.dates.count)")
                for date in fullDayShifts.dates {
                    if !monthModel.fullDays.dates.contains(date) {
                        monthModel.fullDays.dates.append(date)
                    }
                    if !monthModel.selections.contains(date) {
                        monthModel.selections.append(date)
                    }
                }
            }
        }
    }
    
    func saveAvailability() {
        print("save availability to realm")
        guard let availability = state.user?.userPreferences?.availability else {
            print("No user availability found! major problem!")
            return
        }
        print("have user availability")
        try! userRealm.write {
            
            if let usersAvailableMornings = availability.filter(NSPredicate(format: "type == %@", "Morning")).first {
                print("have morning dates")
                
//                for date in usersAvailableMornings.dates {
//                    if let pos = usersAvailableMornings.dates.firstIndex(of: date) {
//                        usersAvailableMornings.dates.remove(at: pos)
//                        print("removed \(date) from mornings")
//                    }
//                }
                usersAvailableMornings.dates.removeAll()
                
                for date in monthModel.mornings.dates {
                    usersAvailableMornings.dates.append(date)
                    print("added \(date) to mornings")
                }
                
            }
            
            if let usersAvailableAfternoons = availability.filter(NSPredicate(format: "type == %@", "Afternoon")).first {
                
//                for date in usersAvailableAfternoons.dates {
//                    if let pos = usersAvailableAfternoons.dates.firstIndex(of: date) {
//                        usersAvailableAfternoons.dates.remove(at: pos)
//                        print("removed \(date) from afternoons")
//                    }
//                }
                usersAvailableAfternoons.dates.removeAll()
                
                for date in monthModel.afternoons.dates {
                    usersAvailableAfternoons.dates.append(date)
                    print("added \(date) to afternoons")
                }
            }
            
            if let usersAvailableFullDays = availability.filter(NSPredicate(format: "type == %@", "FullDay")).first {
                
//                for date in usersAvailableFullDays.dates {
//                    if let pos = usersAvailableFullDays.dates.firstIndex(of: date) {
//                        usersAvailableFullDays.dates.remove(at: pos)
//                        print("removed \(date) from fullDays")
//                    }
//                }
                usersAvailableFullDays.dates.removeAll()
                
                for date in monthModel.fullDays.dates {
                    usersAvailableFullDays.dates.append(date)
                    print("added \(date) to fullDays")
                }
            }
            
            // find the crew member and update the availability!
            updateCrewMember()
            
            
        }
        
        func updateCrewMember() {
            let publicConfig =  app.currentUser!.configuration(partitionValue: "public=public")
             let realm = try! Realm(configuration: publicConfig)
            let crewMember = realm.objects(CrewMember.self).filter(NSPredicate(format: "_id == %@", state.user?._id ?? "")).first
            
            try! Realm(configuration: publicConfig).write {
                guard crewMember != nil else {
                    print("crewMember nil")
                    return
                }
                
                guard let availability = state.user?.userPreferences?.availability else {
                    print("Availability is nil")
                    return
                    
                }
                
                print("writing changes.")
                crewMember!.thaw()?.availability.removeAll()
                for i in availability {
                    let availableDays = AvailableDays()
                    availableDays.type = i.type
                    availableDays.dates = i.dates
                    crewMember!.thaw()?.availability.append(availableDays)
                }
                
            }
        }
    }
    
//    func initData() {
////        guard let date = controlDate else { return }
////        if monthDataModel.fullDays.dates.contains(date) {
////            shiftColor = .fullDay
////        }
////
////        if monthDataModel.mornings.dates.contains(date) {
////            shiftColor = .halfDayAM
////        }
////
////        if monthDataModel.afternoons.dates.contains(date) {
////            shiftColor = .halfDayPM
////        }
//
//        guard let availability = state.user?.userPreferences?.availability else { return }
//        if availability.count > 0 {
//            if let morningShifts = availability.filter(NSPredicate(format: "type == %@", "Morning")).first {
//                for date in morningShifts.dates {
//                    if !monthModel.mornings.dates.contains(date) {
//                        monthModel.mornings.dates.append(date)
//                    }
//                }
//            }
//
//            if let afternoonShifts = availability.filter(NSPredicate(format: "type == %@", "Afternoon")).first {
//                for date in afternoonShifts.dates {
//                    if !monthModel.afternoons.dates.contains(date) {
//                        monthModel.afternoons.dates.append(date)
//                    }
//                }
//            }
//
//
//            if let fullDayShifts = availability.filter(NSPredicate(format: "type == %@", "FullDay")).first {
//
//                for date in fullDayShifts.dates {
//                    if !monthModel.fullDays.dates.contains(date) {
//                        monthModel.fullDays.dates.append(date)
//                    }
//                }
//            }
//        }
//    }
}
