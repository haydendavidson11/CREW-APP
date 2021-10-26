//
//  BuildScheduleView.swift
//  BuildScheduleView
//
//  Created by Hayden Davidson on 8/13/21.
//

import SwiftUI
import RealmSwift

struct BuildScheduleView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.realm) var publicRealm
    @Environment(\.calendar) var calendar
    @State private var date = Date()
    
    @ObservedResults(CrewMember.self) var crewMembers
    
    var filteredCrewMembers : Results<CrewMember> {
        guard let userCompany = state.user?.companyID else { return crewMembers }
        
        return crewMembers.filter(NSPredicate(format: "companyID == %@", userCompany))
    }
    
    var monthString:  String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"
        return dateFormatter.string(from: date)
    }
    
    
    var yearString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: date)
    }
    
    
    var weekDays: [Date] {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        
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
    
    var body: some View {
        VStack {
            
            HStack {
                Button( action: {
                    withAnimation {
                        decrMonth()
                    }
                } ) {
                    Image(systemName: "chevron.left").font(.title2)
                }.padding()
                
                Text("\(monthString) \(yearString)")
                
                Button( action: {
                    withAnimation {
                        incrMonth()
                    }
                } ) {
                    Image(systemName: "chevron.right").font(.title2)
                }.padding()
                
                
            }
            List(0..<weekDays.count, id: \.self) { index in
                NavigationLink {
//                    BuildCrewView(date: weekDays[index])
                    Text("Select from available crews")
                } label: {
                    HStack {
                        VStack(alignment: .center, spacing: 3) {
                            Text(getFullWeekDayName(date: weekDays[index]))
                                .font(.footnote)
                            Text(getDayOfMonth(date:weekDays[index]))
                                .bold()
                        }
                        .frame(width: 40)
                        .foregroundColor(calendar.isDateInToday(weekDays[index]) ? .brandPrimary : .primary)
                        Spacer()
                        
                        ForEach(filteredCrewMembers) { crewMember in
                            if crewMember.availability.contains(where: { setOfDays in
                                setOfDays.dates.contains(weekDays[index])
                            }) {
                                AvatarThumbNailView(photo: crewMember.avatarImage ?? Photo(), imageSize: 40)
                            }
                        }
                        
                    }
                }
                
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Build Schedule")
    }
    
    func decrMonth() {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .month, value: -1, to: date) {
            date = newDate
        }
    }
    
    func incrMonth() {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .month, value: 1, to: date) {
            date = newDate
        }
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
}


struct BuildScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        BuildScheduleView()
    }
}
