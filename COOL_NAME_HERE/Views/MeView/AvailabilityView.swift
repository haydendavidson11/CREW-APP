//
//  DatePickerView.swift
//  DatePickerView
//
//  Created by Hayden Davidson on 7/30/21.
//

import SwiftUI
import RealmSwift

struct AvailabilityView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.realm) var userRealm
    
    @State private var anyDays = [Date]()
    @State private var fullDays = AvailableDays()
    @State private var mornings = AvailableDays()
    @State private var afternoons = AvailableDays()
    @State private var shiftType: ShiftType = .fullDay
    @State private var showingPicker = false
    @State private var showingAlert = false
    
    var body: some View {
        
        VStack(spacing: 2) {
            
            Picker("Shift Type", selection: $shiftType) {
                ForEach(Array(ShiftType.allCases), id: \.self) {
                    Text($0.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            Divider()
                .padding(.horizontal)
            
            MultiDatePicker(anyDays: $anyDays, mornings: $mornings, afternoons: $afternoons, fullDays: $fullDays, shiftType: $shiftType)
                .environment(\.realmConfiguration,
                              app.currentUser!.configuration(partitionValue: "user=\(state.user?._id ?? "")"))
                .environmentObject(state)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Availability")
        .onAppear {
//            initData()
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
                    if !mornings.dates.contains(date) {
                        mornings.dates.append(date)
                    }
                    if !anyDays.contains(date) {
                        anyDays.append(date)
                    }
                }
            }
            
            if let afternoonShifts = availability.filter(NSPredicate(format: "type == %@", "Afternoon")).first {
                print("afternoons \(afternoonShifts.dates.count)")
                for date in afternoonShifts.dates {
                    if !afternoons.dates.contains(date) {
                        afternoons.dates.append(date)
                    }
                    if !anyDays.contains(date) {
                        anyDays.append(date)
                    }
                }
            }
            
            
            if let fullDayShifts = availability.filter(NSPredicate(format: "type == %@", "FullDay")).first {
                print("full days \(fullDayShifts.dates.count)")
                for date in fullDayShifts.dates {
                    if !fullDays.dates.contains(date) {
                        fullDays.dates.append(date)
                    }
                    if !anyDays.contains(date) {
                        anyDays.append(date)
                    }
                }
            }
        }
    }

}

struct DatePickerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            AvailabilityView()
        }
        .accentColor(.brandPrimary)
    }
}
