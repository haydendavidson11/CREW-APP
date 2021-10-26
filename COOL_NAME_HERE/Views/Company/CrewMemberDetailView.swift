//
//  CrewMemberDetailView.swift
//  CrewMemberDetailView
//
//  Created by Hayden Davidson on 8/10/21.
//

import SwiftUI
import RealmSwift

struct CrewMemberDetailView: View {
    @EnvironmentObject var state: AppState
    
    
    var crewMember: CrewMember
    
    var date: Date?
    
    
    @State private var showingAvailability = false
    @State private var showingSchedule = false
    @State private var showingSendShiftRequestView = false
    @State private var showChangeRoleView = false
    @State private var showingActionSheet = false
    @State private var actionSheetTitle = ""
    @State private var actionSheetMessage = ""
    
    
    var body: some View {
        
        NavigationView{
            ScrollView(.vertical) {
                VStack {
                    VStack {
                        AvatarThumbNailView(photo: crewMember.avatarImage ?? Photo(), imageSize: 100 )
                        
                        Text(crewMember.displayName ?? "")
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                        
                        Text(crewMember.role ?? "")
                            .font(.caption)
                        
                        if crewMember.shareContactInfo.value == true {
                            HStack {
                                Spacer()
                                Button {
                                    UIApplication.shared.open(URL(string: "tel:\(crewMember.phone ?? "")")!)
                                } label: {
                                    Image(systemName: "phone.circle")
                                        .resizable()
                                        .foregroundColor(.brandPrimary)
                                        .scaledToFit()
                                        .frame(width: 50)
                                        
                                }
                                .padding(.horizontal)
                               
                                
                                Button {
                                    UIApplication.shared.open(URL(string: "sms:\(crewMember.phone ?? "")")!)
                                } label: {
                                    Image(systemName: "message.circle")
                                        .resizable()
                                        .foregroundColor(.brandPrimary)
                                        .scaledToFit()
                                        .frame(width: 50)
                                }
                                .padding(.horizontal)
                                Spacer()

                            }
                        }
                        
                    }.padding()
                    
                    if crewMember.shareContactInfo.value == true {
                        HStack {
                            Section {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Image(systemName: "envelope")
                                        Link(crewMember.email ?? "no email", destination: URL(string: "mailto:\(crewMember.email ?? "no email")")!)
                                    }
                                    HStack {
                                        Image(systemName: "phone")
                                        Link(crewMember.phone ?? "", destination: URL(string: "tel:\(crewMember.phone ?? "")")!)
                                    }
                                    
                                    HStack(alignment: .top) {
                                        Image(systemName: "location.circle")
                                        VStack(alignment: .leading) {
                                            Text(crewMember.address?.street ?? "")
                                            Text("\(crewMember.address?.city ?? ""), \(crewMember.address?.state ?? "") \(crewMember.address?.zip ?? "")")
                                            Text(crewMember.address?.country ?? "")
                                        }
                                    }
                                }
                            }
                            Spacer()
                        }
                        .padding(.vertical)
                    }
                    
                    
                    if date != nil {
                        CallToActionButton(title: "Schedule for \(date!.formatted(date: .abbreviated, time: .omitted))", action: {
                            //show send shift request view
                            showingSendShiftRequestView = true
                        })
                    }
                    
                    if state.canEditAndDelete {
                        NavigationLink(isActive: $showChangeRoleView) {
                            RoleChangeRequest(crewMember: crewMember)
                                .environment(\.realmConfiguration,
                                              app.currentUser!.configuration(partitionValue: "public=public"))
                        } label: {
                            HStack {
                                Text("Change Position")
                                    .font(.title)
                                Button {
                                    showChangeRoleView = true
                                } label: {
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.brandPrimary)
                                }
                                Spacer()
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    HStack {
                        Text("Availability")
                            .font(.title)
                        Button {
                            withAnimation {
                                self.showingAvailability.toggle()
                            }
                            
                        } label: {
                            Image(systemName: "chevron.right")
                                .rotationEffect(showingAvailability ? .degrees(90) : .degrees(0))
                                .foregroundColor(.brandPrimary)
                        }
                        Spacer()
                        
                    }
                    if showingAvailability {
                        CrewMemberAvailabilityView(crewMember: crewMember)
                            .environment(\.realmConfiguration,
                                          app.currentUser!.configuration(partitionValue: "public=public"))
                    }
                    
                    HStack {
                        Text("Schedule")
                            .font(.title)
                        Button {
                            withAnimation {
                                self.showingSchedule.toggle()
                            }
                        } label: {
                            Image(systemName: "chevron.right")
                                .rotationEffect(showingSchedule ? .degrees(90) : .degrees(0))
                                .foregroundColor(.brandPrimary)
                            
                        }
                        Spacer()
                        
                    }
                    
                    if showingSchedule {
                        CrewMemberScheduleView(crewMember: crewMember)
                            .environment(\.realmConfiguration,
                                          app.currentUser!.configuration(partitionValue: "user=\(state.user?._id ?? "")"))
                    }
                    
                    if state.canEditAndDelete {
                        Spacer()
                        Button {
                            // remove crew member from company.
                            actionSheetTitle = "Remove \(crewMember.displayName ?? "Crew Member")?"
                            actionSheetMessage = "This crew member will be removed from your company. They will no longer have access to any company information, They are removed from crews and jobs. They are also removed from the schedule. Are you sure you want to remove them?"
                            showingActionSheet = true
                        } label: {
                            HStack {
                                Spacer()
                                Text("Remove from company")
                                    .font(Font.body.weight(.semibold))
                                    .padding(.vertical)
                                Spacer()
                            }
                            .foregroundColor(.white)
                            .background(Color.halfDayPM)
                            .cornerRadius(50.0)
                            
                        }
                        .padding()
                        
                    }
                    
                }
                .padding()
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingSendShiftRequestView) {
                SendShiftRequestView(crewMember: crewMember, date: date != nil ? date! : Date())
            }
            .actionSheet(isPresented: $showingActionSheet) {
                ActionSheet(title: Text(actionSheetTitle), message: Text(actionSheetMessage), buttons: [.default(Text("Remove from Company"), action: {
                    // remove crewMember from company
                    Remove(crewMember: crewMember)
                    
                }), .cancel()])
            }
        }
    }
    
    func Remove(crewMember: CrewMember) {
        removeFromJobs(crewMember: crewMember)
        removeFromCompany(crewMember: crewMember)
        app.currentUser!.functions.RemoveUserFromCompany([AnyBSON("\(crewMember._id)")])
    }
    
    func removeFromCompany(crewMember: CrewMember) {
        // find the company and remove the crewMember from the appropriate role array.
        let publicConfig = app.currentUser!.configuration(partitionValue: "public=public")
        let realm = try! Realm(configuration: publicConfig)
        let company = realm.objects(Company.self).first { company in
            company._id == crewMember.companyID
        }
        guard company != nil else { return }
        try! realm.write {
            if company!.admins.contains(crewMember._id) , let pos = company!.admins.firstIndex(of: crewMember._id) {
                company!.admins.remove(at: pos)
            }
            
            if company!.managers.contains(crewMember._id) , let pos = company!.managers.firstIndex(of: crewMember._id) {
                company!.thaw()?.managers.remove(at: pos)
            }
            
            if company!.members.contains(crewMember._id) , let pos = company!.members.firstIndex(of: crewMember._id) {
                company!.members.remove(at: pos)
            }
            // remove the crewMember from crews.
            for crew in company!.crews {
                if crew.members.contains(crewMember._id), let pos = crew.members.firstIndex(of: crewMember._id) {
                    crew.members.remove(at: pos)
                }
            }
        }
        
    }
    
    func removeFromJobs(crewMember: CrewMember) {
        // remove crew member from any jobs
        let companyConfig = app.currentUser!.configuration(partitionValue: "public=\(crewMember.companyID ?? "")")
        let realm = try! Realm(configuration: companyConfig)
        let projects = realm.objects(Project.self)
        for project in projects {
            if project.crew.contains(crewMember._id), let pos = project.crew.firstIndex(of: crewMember._id) {
                try! realm.write {
                    project.crew.remove(at: pos)
                }
            }
        }
        
    }
}

struct CrewMemberDetailView_Previews: PreviewProvider {
    static var crewMember = CrewMember()
    
    static var previews: some View {
        CrewMemberDetailView(crewMember: crewMember)
    }
}







struct CrewMemberAvailabilityView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.realm) var publicRealm
    
    @ObservedResults(Request.self) var requests
    
    var crewMember: CrewMember
    
    
    
    var morningShifts: [Date] {
        var dates = [Date]()
        let mornings = crewMember.availability.filter(NSPredicate(format: "type == %@", "Morning")).first
        let today = Date()
        guard let mornings = mornings else { return dates }

        for date in mornings.dates {
            if date > today {
                dates.append(date)
            }
        }
        return dates.sorted()
    }
    
    var afternoonShifts: [Date] {
        var dates = [Date]()
        let afternoons = crewMember.availability.filter(NSPredicate(format: "type == %@", "Afternoon")).first
        let today = Date()
        guard let afternoons = afternoons else { return dates }

        for date in afternoons.dates {
            if date > today {
                dates.append(date)
            }
        }
        return dates.sorted()
    }
    
    var fullDayShifts: [Date] {
        var dates = [Date]()
        let fullDays = crewMember.availability.filter(NSPredicate(format: "type == %@", "FullDay")).first
        let today = Date()
        guard let fullDays = fullDays else { return dates }

        for date in fullDays.dates {
            if date > today {
                dates.append(date)
            }
        }
        return dates.sorted()
    }
    
    func pendingShift(date: Date) -> Bool {
        let crewMemberRequest = requests.filter(NSPredicate(format: "recipient == %@", crewMember.userName ?? ""))
        let shiftRequest = crewMemberRequest.filter(NSPredicate(format: "type == %@", "shift"))
        
        for request in shiftRequest {
            guard let shiftDate = request.shift?.date else { return false }
            if date == shiftDate {
                return true
            }
        }
        return false
        
    }
    
    var formatter : DateFormatter {
        let newFormatter = DateFormatter()
        newFormatter.dateStyle = .short
        return newFormatter
    }
    
    var body: some View {
        if morningShifts.count == 0 && afternoonShifts.count == 0 && fullDayShifts.count == 0 {
            Text("No availability at this time")
        } else {
            VStack(alignment: .leading) {
                
                //list morning shifts
                
                    if morningShifts.count > 0 {
                        HStack {
                            Text("Mornings")
                                .font(.caption)
                                .foregroundColor(.brandPrimary)
                            Spacer()
                        }
                        
                        ForEach(morningShifts, id: \.self) { date in
                            HStack {
                                Text(formatter.string(from: date))
                                Spacer()
                                if state.user != nil {
                                    if state.user!.role == "Manager" || state.user!.role == "Admin" {
                                        if pendingShift(date: date) {
                                            Text("Pending...")
                                                .foregroundColor(.brandPrimary)
                                        } else {
                                            NavigationLink(destination: SendShiftRequestView(crewMember: crewMember, date: date)
                                                            .environment(\.realmConfiguration,
                                                                          app.currentUser!.configuration(partitionValue: "public=public"))) {
                                                Text("Schedule")
                                                    .foregroundColor(.brandPrimary)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.top, 4)
                        }
                        Divider()
                            .padding(.horizontal)
                    }
                
                
                
                
                //list afternoon shifts
                
                    if afternoonShifts.count > 0 {
                        HStack {
                            Text("Afternoons")
                                .font(.caption)
                                .foregroundColor(.brandPrimary)
                            Spacer()
                        }
                        
                        ForEach(afternoonShifts, id: \.self) { date in
                            HStack {
                                Text(formatter.string(from: date))
                                Spacer()
                                if state.user != nil {
                                    if state.user!.role == "Manager" || state.user!.role == "Admin" {
                                        if pendingShift(date: date) {
                                            Text("Pending...")
                                                .foregroundColor(.brandPrimary)
                                        } else {
                                            NavigationLink(destination: SendShiftRequestView(crewMember: crewMember, date: date)
                                                            .environment(\.realmConfiguration,
                                                                          app.currentUser!.configuration(partitionValue: "public=public"))) {
                                                Text("Schedule")
                                                    .foregroundColor(.brandPrimary)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.top, 4)
                        }
                        Divider()
                            .padding(.horizontal)
                    }
                
                
                //list full day shifts
                
                    if fullDayShifts.count > 0 {
                        HStack {
                            Text("Full Days")
                                .font(.caption)
                                .foregroundColor(.brandPrimary)
                            Spacer()
                        }
                        
                        ForEach(fullDayShifts.sorted(), id: \.self) { date in
                            HStack {
                                Text(formatter.string(from: date))
                                Spacer()
                                if state.user != nil {
                                    if state.user!.role == "Manager" || state.user!.role == "Admin" {
                                        if pendingShift(date: date) {
                                            Text("Pending...")
                                                .foregroundColor(.brandPrimary)
                                        } else {
                                            NavigationLink(destination: SendShiftRequestView(crewMember: crewMember, date: date)
                                                            .environment(\.realmConfiguration,
                                                                          app.currentUser!.configuration(partitionValue: "public=public"))) {
                                                Text("Schedule")
                                                    .foregroundColor(.brandPrimary)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.top, 4)
                        }
                    }
                

                
            }
            .accentColor(.brandPrimary)
        }
    }
}

struct CrewMemberScheduleView: View {
    @Environment(\.realm) var userRealm
    @EnvironmentObject var state : AppState
    
    
    var crewMember: CrewMember
    
    var schedule: [Shift] {
        let today = Date()
        var shifts = [Shift]()
        for shift in crewMember.schedule {
            if let date = shift.date {
                if date > today {
                    shifts.append(shift)
                }
            }
        }
        return shifts.sorted { lhs, rhs in
            guard let lDate = lhs.date else { return  false }
            guard let rDate = rhs.date else { return false }
            return lDate > rDate
        }
    }
    
    
    
    var body: some View {
        
        VStack(alignment: .leading) {
            if crewMember.schedule.count > 0 {
                ForEach(schedule) { shift in
                    HStack {
                        ShiftView(shift: shift, vertical: false)
                        Spacer()
                        
                        //EDIT SHIFT BUTTON
//                        if state.user != nil {
//                            if state.canEditAndDelete {
//                                Text("Edit")
//                                    .foregroundColor(.brandPrimary)
//                                    .contextMenu(ContextMenu(menuItems: {
//                                        Button(role: .destructive) {
//                                            print("remove from schedule")
//                                            try! userRealm.write {
//                                                if let pos = state.user?.userPreferences?.schedule.firstIndex(of: shift) {
//                                                    state.user?.userPreferences?.schedule.remove(at: pos)
//                                                }
//                                            }
//                                        } label: {
//                                            Text("Remove From Schedule")
//                                        }
//
//                                        Button() {
//
//                                        } label: {
//                                            Text("Change Details")
//                                        }
//
//
//                                    }))
//
//                            }
//                        }
                    }
                }
            } else {
                Text("No shifts on schedule")
            }
        }
    }
}
