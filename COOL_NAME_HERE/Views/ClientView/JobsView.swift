//
//  JobsView.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 3/30/21.
//

import SwiftUI
import RealmSwift

struct JobsView: View {
    
    @EnvironmentObject var state: AppState
    
    @ObservedRealmObject var client: Client
    @ObservedResults(Project.self) var projects
    
    @State private var showAddJobSheet = false
    @State private var showingJobs = false
    @State var crewMember = CrewMember()
    
    var filteredProjects: Results<Project> {
        return projects.filter(NSPredicate(format: "client == %@",  "\(client.firstName) \(client.lastName)"))
    }
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "wrench.and.screwdriver")
                Text("Show Jobs")
                Spacer()
                Toggle("Show Jobs", isOn: $showingJobs)
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: Color.brandPrimary))
            }
            .padding([.leading, .trailing])
            
            if showingJobs {
                HStack {
                    Spacer()
                    if state.canAddClient {
                        Button("Add") {
                            showAddJobSheet.toggle()
                        }
                        .foregroundColor(.primary)
                    }
                }.padding()
                if filteredProjects.count > 0 {
                    
                    ForEach(filteredProjects, id: \._id) { project in
                        VStack(alignment: .leading) {
                            CompactCardView(project: project)
                                .padding(.horizontal)
                            Divider()
                                .padding(.horizontal)
                        }
                    }
                    
                } else {
                    Text("No Jobs")
                }
            }
        }
        .sheet(isPresented: $showAddJobSheet) {
            AddJobView(forClient: client)
                .environment(\.realmConfiguration,
                              app.currentUser!.configuration(partitionValue: "public=\(state.user?.companyID ?? "")"))
        }
    }
}

struct LinkLabelView: View {
    @EnvironmentObject var state: AppState
    @ObservedRealmObject var job: Job
    var body: some View {
        HStack {
            Text("Status: \(job.isActive ?? "Complete")")
            Text("Start Date: \(getJobStartDateString(for: job))")
            if job.completionDate != nil {
                Text("Completion Date: \(getJobCompletionDateString(for: job))")
            }
            Spacer()
            Image(systemName: "chevron.right")
            
        }
        .padding()
    }
    
    
    func getJobStartDateString(for job: Job) -> String {
        var dateString = ""
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        if let startDate = job.startDate {
            dateString = formatter.string(from: startDate)
        }
        return dateString
    }
    
    func getJobCompletionDateString(for job: Job) -> String {
        var dateString = ""
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        if let startDate = job.completionDate {
            dateString = formatter.string(from: startDate)
        }
        return dateString
    }
}

//struct JobsView_Previews: PreviewProvider {
//    static var previews: some View {
//        JobsView()
//    }
//}
