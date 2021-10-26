//
//  BuildCompanySchedule.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 9/25/21.
//

import SwiftUI
import RealmSwift

struct BuildCompanySchedule: View {
    @EnvironmentObject var state: AppState
    
    @State private var date = Date()
    
    @State var crewMembers = [CrewMember]()
    
    @State var crews = [Crew]()
    
    @State var jobs = [Project]()
    @State var showingList = 1
    
    
    var body: some View {
        
        VStack(alignment: .center) {
            DatePicker("Date", selection: $date, displayedComponents: [.date])
                .datePickerStyle(.graphical)
            
            Divider()
            
            
            
                HStack(alignment: .bottom, spacing: 30) {
                    VStack {
                        Image(systemName: "person.fill")
                        Text("People")
                    }
                    .onTapGesture {
                        showingList = 1
                    }
                    .padding()
                    .background(Circle()
                                    .strokeBorder(lineWidth: 2)
                                    .background(showingList == 1 ? Circle().fill(Color.brandPrimary) : nil)
                                    .foregroundColor(.brandPrimary))
                    VStack {
                        Image(systemName: "person.3.fill")
                        Text("Crews")
                    }
                    .padding()
                    .background(Circle()
                                    .strokeBorder(lineWidth: 2)
                                    .background(showingList == 2 ? Circle().fill(Color.brandPrimary) : nil)
                                    .foregroundColor(.brandPrimary))
                    .onTapGesture {
                        showingList = 2
                    }
                    
                    VStack {
                        Image(systemName: "wrench.and.screwdriver.fill")
                        Text("Jobs")
                    }
                    .padding()
                    .background(Circle()
                                    .strokeBorder(lineWidth: 2)
                                    .background(showingList == 3 ? Circle().fill(Color.brandPrimary) : nil)
                                    .foregroundColor(.brandPrimary))
                    .onTapGesture {
                        showingList = 3
                    }
                }
//                .padding(.bottom)

            if showingList == 1 {
                CrewMemberList(crewMembers: $crewMembers, date: date)
                    .tag(1)
                    .onAppear {
                        getAvailableCrewMembers()
                    }
            }
            
            if showingList == 2 {
                CrewList(crew: $crews, date: date)
                    .tag(2)
            }
            
            if showingList == 3 {
                JobsToBeScheduledList(jobs: $jobs)
                    .tag(3)
            }
            Spacer()
        }
        .navigationBarTitle("Schedule Builder")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            getAvailableCrews()
            getAvailableCrewMembers()
            getToBeScheduledJobs()
        }
        .onChange(of: date) { newValue in
            
                getAvailableCrews()
                getAvailableCrewMembers()
                getToBeScheduledJobs()
            
        }
    }
    
    func getAvailableCrewMembers() {
        print("getting CrewMembers")
        // Empty the CrewMember array
        crewMembers.removeAll()
        
        // get all the crewMembers for this business available on this day
        
        let publicConfig =  app.currentUser!.configuration(partitionValue: "public=public")
        
       
       let realm = try! Realm(configuration: publicConfig)
       // get the business's crewMembers
        guard let userCompany = state.user?.companyID else { return }
        let businessMembers = realm.objects(CrewMember.self).filter(NSPredicate(format: "companyID == %@", userCompany))
        
        // filter through the business's crewMembers and check if the date selected by the picker is in their available days list.
        for member in businessMembers {
                for availableDays in member.availability {
                    if availableDays.dates.contains(where: { date in
                        date.formatted(date: Date.FormatStyle.DateStyle.numeric, time: .omitted) == self.date.formatted(date: Date.FormatStyle.DateStyle.numeric, time: .omitted)
                    }) {
                        crewMembers.append(member)
                    }
                }
        }
    }
    
    func getAvailableCrews() {
        // Get all available Crews for the selected date
        print("getting Crews.")
        crews.removeAll()
        
        guard let userCompany = state.user?.companyID else { return }
        print("have user company")
        
        
        // open the public realm to be able to get the company info
        let companyConfig =  app.currentUser!.configuration(partitionValue: "public=public")
        let companyRealm = try! Realm(configuration: companyConfig)
        
        // get all crewMembers in the users company
        let crewMembers = companyRealm.objects(CrewMember.self).filter(NSPredicate(format: "companyID == %@", userCompany))
        
        // get the users Company Object
        let company = companyRealm.objects(Company.self).first { company in
            company._id == userCompany
        }
        
        // ensure we have crew members
        guard crewMembers.count > 0 else { return }
        print("have \(crewMembers.count) crew members")
        
        // ensure we have a company
        guard company != nil else { return }
        print("have company")
        
        var membersToCheck = [CrewMember]()
        
        for crew in company!.crews {
            membersToCheck.removeAll()
            for member in crew.members {
                guard let person = crewMembers.filter(NSPredicate(format: "_id == %@", member)).first else { return }
                membersToCheck.append(person)
            }
            
            let addCrew = membersToCheck.allSatisfy { CrewMember in
                CrewMember.availability.contains { AvailableDays in
                    AvailableDays.dates.contains { date in
                        date.formatted(date: Date.FormatStyle.DateStyle.numeric, time: .omitted) == self.date.formatted(date: Date.FormatStyle.DateStyle.numeric, time: .omitted)
                    }
                }
            }
            
            print("Add Crew \(crew.name ?? "")")
            print(addCrew)
            
            if addCrew && !crews.contains(crew) {
                crews.append(crew)
            }
            
        }
        
    }
    
    func getToBeScheduledJobs() {
        // Empty the Jobs Array
        jobs.removeAll()
        
        // get all jobs that are ready to be scheduled
        
        let businessConfig =  app.currentUser!.configuration(partitionValue: "public=\(state.user?.companyID ?? "")")
        let realm = try! Realm(configuration: businessConfig)
        let jobsToBeScheduled = realm.objects(Project.self).filter(NSPredicate(format: "category == %@", Category.toBeScheduled.asString))
        for job in jobsToBeScheduled {
            jobs.append(job)
        }
        
    }
    
    func scheduleJob(job: Project) {
        // Change the start date to the selected date
        // Notify the selected crewMembers
        // change the project category to scheduled.
    }
    
    func scheduleCrewMembers(crewMembers: [CrewMember]) {
        // notify the selected crewMembers
        // add selected crewMembers to the crew list of the project.
        // move date from crewMembers available days to Schedule
    }
    
    func getScheduledCrewMembers() {
        // get all CrewMembers with the selected date included in their schedule
    }
    
    func getScheduledJobs() {
//        get all jobs scheduled on selected date
        
        jobs.removeAll()
        
        // get all jobs that are ready to be scheduled
        
        let businessConfig =  app.currentUser!.configuration(partitionValue: "public=\(state.user?.companyID ?? "")")
        let realm = try! Realm(configuration: businessConfig)
        let scheduledJobs = realm.objects(Project.self).filter(NSPredicate(format: "startDate == %@", date as CVarArg))
        for job in scheduledJobs {
            jobs.append(job)
        }
    }
    
}

struct BuildCompanySchedule_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            BuildCompanySchedule()
        }
    }
}

struct CrewMemberList: View {
    
    @Binding var crewMembers : [CrewMember]
    
    let columns = [GridItem(.flexible()),
                   GridItem(.flexible()),
                   GridItem(.flexible())]
    
    var date: Date?
    
    var body: some View {
        
        if crewMembers.count > 0 {
            LazyVGrid(columns: columns) {
                ForEach(crewMembers , id: \.self) { member in
                    CrewMemberImageView(crewMember: member, date: date)
                }
                
            }
        } else {
            Text("No Crew Members available on this date")
                .padding(.vertical)
        }
    }
}

struct CrewList: View {
    @EnvironmentObject var state: AppState
    
   @Binding var crew: [Crew]
    
    var date: Date?
    
    var body: some View {
        
        if crew.count > 0 {
            List {
                ForEach(crew, id: \.self) { crew in
                    CrewView(crew: crew, date: date)
                }
            }
        } else {
            Text("No Crews available on this date.")
                .padding(.vertical)
        }
    }
}



struct JobsToBeScheduledList: View {
    @EnvironmentObject var state: AppState
    
    @Binding var jobs: [Project]
    
    var body: some View {
        
        if jobs.count > 0 {
            List {
                ForEach(jobs, id: \.self) { job in
                    CompactCardView(project: job)
                        .environment(\.realmConfiguration,
                                      app.currentUser!.configuration(partitionValue: "public=\(state.user?.companyID ?? "")"))
                }
            }
        } else {
            Text("No Jobs ready to be scheduled")
                .padding(.vertical)
        }
    }
}
