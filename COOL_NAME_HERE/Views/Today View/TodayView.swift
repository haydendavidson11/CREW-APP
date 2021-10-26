//
//  TodayView.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 6/20/21.
//

import SwiftUI
import RealmSwift

struct TodayView: View {
    @Environment(\.calendar) var calendar
    @Environment(\.realm) var companyRealm
    @EnvironmentObject var state: AppState
//    @EnvironmentObject var notifications: NotificationHelper
    
    @ObservedResults(Project.self) var projects
    
    
    @State private var showingSheet = false
    @State private var isChecked = false
    @State var userRequestCount = 0
    
    @State private var showingActionSheet = false
    @State private var actionSheetTitle = ""
    @State private var actionSheetMessage = ""
    
    @State private var todaysProjects = [Project]()
    
    @State private var todaysCheckList = [TodoItem]()
    @State private var todaysCrewMembers = [CrewMember]()
    
    
    @State private var currentJobIndex: Int? {
        didSet {
            print("job index: \(currentJobIndex)")
        }
    }
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var currentJob: Project? {
        didSet {
            guard let currentJob = currentJob else {
                return
            }
            withAnimation {
                currentJobIndex = todaysProjects.firstIndex(of: currentJob)
            }
            
        }
    }
    
    var lastJob: Bool {
        guard let currentJob = currentJob else {return false}
        let pos = todaysProjects.firstIndex(of: currentJob)
        guard let pos = pos else { return false }

        if todaysProjects.count - 1 == pos {
            return true
        }
        return false
    }
    
    var firstJob: Bool {
        guard let currentJob = currentJob else {return false}
        let pos = todaysProjects.firstIndex(of: currentJob)
        
        if pos == 0 {
            return true
        }
        return false
    }
    
    var body: some View {
        NavigationView  {
            ScrollView(.vertical) {
                VStack {
                    
                    Section {
                        HStack {
                            Text("Current Job")
                                .bold()
                                .font(.caption)
                                .padding(.horizontal)
                            Spacer()
                        }
                        if currentJob != nil {
                            HStack {
                                
                                if !firstJob && todaysProjects.count > 1 {
                                    withAnimation {
                                        Button {
                                          goToPreviousJob()
                                        } label: {
                                            ZStack {
                                               
                                                RoundedRectangle(cornerRadius: 12)
                                                    .frame(width: 30, height: 50)
                                                    .background(.ultraThinMaterial)
                                                    .cornerRadius(12)
                                                Image(systemName: "chevron.left")
                                                    .foregroundColor(.white)
                                            }
                                            
                                            
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                
                                ProjectCard(project: currentJob!)
                                    .onReceive(timer) { time in
                                        print(time)
                                        for project in todaysProjects {
                                            guard let startTime = project.startTime else { return }
                                            if calendar.isDate(startTime, equalTo: time, toGranularity: .minute) {
                                                self.currentJob = project
                                            }
                                        }
                                    }
                                
                                if !lastJob {
                                    withAnimation {
                                        Button {
                                            actionSheetTitle = "Move to next Job?"
                                            actionSheetMessage = "Would you like to mark this job as complete before moving to the next job OR leave this job incomplete and move to the next job?"
                                            if currentJob?.categoryState != .complete {
                                                showingActionSheet = true
                                            } else {
                                                goToNextJob()
                                            }
                                            
                                        } label: {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 12)
                                                    .frame(width: 30, height: 50)
                                                    .background(.ultraThinMaterial)
                                                    .cornerRadius(12)
                                                Image(systemName: "chevron.right")
                                                    .foregroundColor(.white)
                                            }
                                           
                                                
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                
                                if firstJob || lastJob {
                                    withAnimation {
                                        Spacer()
                                    }
                                }
                                    
                            }
                            .padding(.horizontal)
                            
                            
                                
                                
                        } else {
                            Text("No jobs for today.")
                        }
                    }
                    
                    if todaysProjects.count > 1 {
                        Divider()
                            .padding(.horizontal)
                        Section {
                            HStack {
                                Text("Upcoming Jobs")
                                    .bold()
                                    .font(.caption)
                                    .padding(.horizontal)
                                Spacer()
                            }
                            if todaysProjects.count > 0 && !lastJob {
                                ScrollView(.horizontal) {
                                    ScrollViewReader { reader in
                                        
                                       
                                        HStack {
                                            ForEach(0..<todaysProjects.count, id: \.self) { index in
                                                    ProjectCard(project: todaysProjects[index])
                                                
                                            }
                                            .onAppear(perform: {
                                                guard let currentJobIndex = currentJobIndex else {
                                                    return
                                                }
                                                withAnimation {
                                                    if !lastJob {
                                                        reader.scrollTo(currentJobIndex + 1 , anchor: .leading)
                                                    }
                                                }
                                            })
                                            .onChange(of: currentJobIndex) { v in
                                                guard currentJob != nil else { return }
                                                guard let currentJobIndex = currentJobIndex else {
                                                    return
                                                }
                                                
                                                withAnimation {
                                                    if !lastJob {
                                                        reader.scrollTo(currentJobIndex + 1 , anchor: .leading)
                                                    }
                                                }
                                                
                                                
                                            }
                                        }
                                        
                                    }
                                        
                                }
                                .padding(.leading)
                            } else {
                                Text("There are no jobs coming up.")
                                    .padding()
                            }
                        }
                    }
                    
                    if todaysCrewMembers.count > 0 {
                        Divider()
                            .padding(.horizontal)
                        
                        Section {
                            HStack {
                                Text("Crew")
                                    .bold()
                                    .font(.caption)
                                Spacer()
                            }
                            ZStack {
                                
                                RoundedRectangle(cornerRadius: 12)
                                                .foregroundColor(Color(.secondarySystemBackground))
                                                .opacity(0.7)
                                
                                VStack(spacing: 8) {
                                    
                                    ScrollView(.horizontal) {
                                        HStack {
                                            ForEach(todaysCrewMembers) { crewMember in
                                                NavigationLink {
                                                    CrewMemberDetailView(crewMember: crewMember)
                                                } label: {
                                                    VStack(spacing: 2) {
                                                        AvatarThumbNailView(photo: crewMember.avatarImage ?? Photo(), imageSize: 80)
                                                        Text(crewMember.displayName ?? "")
                                                            .font(.caption)
                                                            .lineLimit(1)
                                                            .minimumScaleFactor(0.5)
                                                    }
                                                }
                                                .buttonStyle(PlainButtonStyle())

                                                
                                            }
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                    }
                    Divider()
                        .padding(.horizontal)
                    
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Check List")
                                    .bold()
                                    .font(.caption)
                                
                                Spacer()
                            }
                            
                            if todaysCheckList.count > 0 {
                                
                                ForEach(todaysProjects, id: \._id) { project in
                                    ProjectTodoView(project: project)
                                    
                                        
                                }
                            } else {
                                Text("Today's checklist is empty.")
                            }
                        }
                        .padding(.horizontal)
                        
                    }
                    .padding(.bottom)
                }
                .navigationTitle("Today")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: state.canAddClient ? Button(action: {showingSheet = true}, label: {
                        Image(systemName: "plus")
                    }) : nil)
                .refreshable {
                    initData()
                }
            }
            
            .sheet(isPresented: $showingSheet) {
                AddJobView()
            }
            .actionSheet(isPresented: $showingActionSheet) {
                ActionSheet(title: Text(actionSheetTitle), message: Text(actionSheetMessage), buttons: [.default(Text("Mark Complete"), action: {
                    // Mark job as completed and move to next
                    markJobComplete()
                    goToNextJob()
                    showingActionSheet = false
                }), .default(Text("Leave Incomplete"), action: {
                    // just move to next job
                    
                    goToNextJob()
                    showingActionSheet = false
                }), .cancel()])
            }
            
        }
        .onAppear(perform: {
            initData()
        })
    }
    
    func initData() {
        getUserRequests()
        getTodaysCrew()
        getTodaysProjects()
        getTodaysTodos()
    }
    
    func getUserRequests() {
        let publicConfig =  app.currentUser!.configuration(partitionValue: "public=public")
        let realm = try! Realm(configuration: publicConfig)
        let requests = realm.objects(Request.self).filter(NSPredicate(format: "recipient == %@", state.user?.userName  ?? ""))
        
        userRequestCount =  requests.count
        
    }
    
    func getTodaysCrew() {
        
        let publicConfig =  app.currentUser!.configuration(partitionValue: "public=public")
        let realm = try! Realm(configuration: publicConfig)
        let crewMembers = realm.objects(CrewMember.self)
        
        for project in todaysProjects {
            for memberID in project.crew {
                let crewMember = crewMembers.first { member in
                    member._id == memberID
                }
                guard crewMember != nil else {
                    print("no crewMember found")
                    return
                    
                }
                if !todaysCrewMembers.contains(crewMember!) {
                    todaysCrewMembers.append(crewMember!)
                }
                print(todaysCrewMembers.count)
            }
        }
    }
    
    func getTodaysProjects() {
        var projectsForToday = [Project]()
        for project in projects {
            if let startDate = project.startDate {
                if calendar.isDateInToday(startDate) && project.isActive == "Active" {
                    projectsForToday.append(project)
                    
                    print("Have Job For Today")
                }
            }
        }
        
        let userProjectsForToday = projectsForToday.filter { project in
            project.crew.contains(state.user?._id ?? "")
        }
        
        self.todaysProjects = userProjectsForToday
        
        
//        guard let startTime = project.startTime else { return }
        currentJob = todaysProjects.first(where: { project in
            guard let startTime = project.startTime else { return false }
            return calendar.isDate(startTime, equalTo: Date(), toGranularity: .hour)
        })
        if currentJob == nil {
            currentJob = todaysProjects.first
        }
        currentJobIndex = todaysProjects.firstIndex(of: currentJob ?? Project())
    }
    
    
  
   
    
    
    func getTodaysTodos() {
        var items = [TodoItem]()
        for project in todaysProjects {
            
                for item in project.todo {
                        items.append(item)
                }
            
        }
        self.todaysCheckList = items
    }
    
    func goToNextJob() {
        print(lastJob)
        print(currentJobIndex)
        guard currentJobIndex != nil else { return }
        if !lastJob {
            currentJob = todaysProjects[currentJobIndex! + 1]
        }
    }
    
    func goToPreviousJob() {
        print(firstJob)
        print(currentJobIndex)
        guard currentJobIndex != nil else { return }
        if !firstJob {
            currentJob = todaysProjects[currentJobIndex! - 1]
        }
    }
    
    func markJobComplete() {
        try! companyRealm.write {
            currentJob?.thaw()?.categoryState = .complete
        }
    }
    
    
}

struct allRequestView: View {
    @EnvironmentObject var state: AppState
    
    @ObservedResults(Request.self) var requests
    
    @State private var filter = ""
    
    var userRequests: Results<Request> {
        print("\(requests.count) requests")
        return requests.filter(NSPredicate(format: "recipient == %@", state.user!.userName))
    }
    
    

    var filteredRequests: Results<Request> {
        if filter.isEmpty {
            return requests.filter(NSPredicate(format: "recipient == %@", state.user!.userName))
        } else {
            return userRequests.filter(NSPredicate(format: "type == %@", filter))
        }
    }
    
    var body: some View {
        VStack {
            if filteredRequests.count > 0 {
                List {
                    ForEach(filteredRequests) { request in
                        RequestView(request: request)
                            .environment(\.realmConfiguration,
                                          app.currentUser!.configuration(partitionValue: "public=public"))
                        
                    }
                    .onDelete(perform: $requests.remove)
                }
            } else {
                Text("You have no requests at this time.")
                    .padding()
            }
        }
        .navigationTitle("Requests")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: FilterButton(filter: $filter))
    }
}

struct TodayView_Previews: PreviewProvider {
    static var previews: some View {
        TodayView()
    }
}

struct ProjectTodoView: View {
    @EnvironmentObject var state: AppState
    @ObservedRealmObject var project: Project
    
    var body: some View {
        if project.todo.count > 0 {
            VStack(alignment: .leading) {
                HStack {
                    Text(project.name ?? "")
                    Spacer()
                    NavigationLink {
                        AddTodoItemView(project: project)
                    } label: {
                        Image(systemName: "plus")
                    }
                    
                }
                Divider()
                    .padding(.horizontal)
                ForEach(project.todo, id: \._id) { item in
                        TodoItemView(item: item, project: project)
                }
            }
            .padding(5)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
//            .onChange(of: projects) { v in
//               updateTodos()
//            }
        }
    }
}
