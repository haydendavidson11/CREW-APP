//
//  JobsList.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 6/13/21.
//

import SwiftUI
import RealmSwift

struct JobsList: View {
    @EnvironmentObject var state: AppState
    @ObservedResults(Project.self) var projects
    
    @State private var showingAddSheet = false
    @State private var searchFilter = ""
    
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    
    var filteredProjects: Results<Project> {
        if searchFilter.isEmpty {
            return projects
        } else {
            return projects.filter(NSPredicate(format: "client CONTAINS[C] %@", searchFilter)).sorted(byKeyPath: "startDate", ascending: true)
        }
    }
    
    init() {
        UITableView.appearance().backgroundColor = .systemBackground
    }
    
    var body: some View {
        
        NavigationView {
            VStack {
                if projects.isEmpty {
                    Text("Add jobs by pressing the + button in the top right corner")
                        .padding()
                } else {
                   
                    List {
                        ForEach(filteredProjects, id: \._id) { project in
                            CompactCardView(project: project)
                        }
                        .onDelete(perform: state.canEditAndDelete ? $projects.remove : nil)
                        .listRowSeparator(.hidden)
                    }
                    .searchable(text: $searchFilter)
                    
                }
            }
            .navigationBarItems(trailing: state.canAddClient ? Button(action: {showingAddSheet = true}, label: {
                Image(systemName: "plus")
            }): nil )
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Jobs")
            .sheet(isPresented: $showingAddSheet) {
                AddJobView()
                    .environment(\.realmConfiguration,
                                  app.currentUser!.configuration(partitionValue: "public=\(state.user?.companyID ?? "")"))
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}

struct JobsList_Previews: PreviewProvider {
    static var previews: some View {
        JobsList()
    }
}
