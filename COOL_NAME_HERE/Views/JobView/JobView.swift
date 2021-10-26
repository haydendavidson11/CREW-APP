//
//  JobView.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 5/18/21.
//

import SwiftUI
import RealmSwift

struct JobView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.realm) var publicRealm
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedRealmObject var project: Project
    @ObservedResults(CrewMember.self) var crewMembers
    
    @State private var edit = false
    @State private var isActiveJob = ["Active", "Complete"]
    @State private var jobStatus = 0
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    @State private var startTime = Date()
    @State private var startDate = Date()
    @State private var completionDate = Date()
    @State private var estimatedTimeToComplete = 0
    @State private var crew = Crew()
    @State private var crewMemberID = ""
    @State private var materialType = ""
    @State private var materialQuantity = 0.0
    @State private var itemDescription = ""
    
    
    
    var body: some View {

        Form {
            Section(header: Text("Client")) {
                Text(project.client)
                
            }
            Section(header: Text("Job Status")) {
                Picker("Is Active", selection: $jobStatus) {
                    ForEach(0..<isActiveJob.count) {
                        Text(isActiveJob[$0])
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
            }
            Section(header: Text("Crew")) {
                if project.assignedCrew?.members.count ?? 0 > 0 {
                    ForEach(project.assignedCrew!.members, id: \.self) { memberID in
                        Text(getCrewName(memberId: memberID))
                    }
                }
            }
            Section(header: Text("Add Crew")) {
                Picker("Crew Members", selection: $crewMemberID) {
                    ForEach(crewMembers, id: \._id) { member in
                        Text(member.displayName ?? "")
                    }
                }
                Button("Add") {
                    let crewMember = crewMembers.filter(NSPredicate(format: "_id == %@", crewMemberID))
                    if let id = crewMember.first?._id {
                        try! publicRealm.write {
                            let crew = self.crew
                            //
                            if project.assignedCrew != nil {
                                project.thaw()?.assignedCrew?.members.append(id)
                                self.crew = project.assignedCrew!
                            } else {
                                crew.members.append(id)
                                project.thaw()?.assignedCrew = crew
                            }
                        }
                    } else {
                        print("not match for crewMember id")
                    }
                }
            }
            if project.materials.count > 0 {
                Section(header: Text("Job Materials")) {
                    
                    ForEach(project.materials, id: \.self) { material in
                        HStack(alignment: .center) {
                            Text("Type:")
                            Text(material.type ?? "")
                            Divider()
                            Text("Quantity:")
                            Text("\(material.quantity.value ?? 0.0, specifier: "%g")")
                            Divider()
                            Text("Color:")
                            Text(material.itemDescription ?? "")
                            
                        }
                    }
                }
            }
            
            Section(header: Text("Add Material")) {
                TextField("Type", text: $materialType)
                Stepper("Quantity \(materialQuantity, specifier: "%g")", onIncrement: {materialQuantity += 1}, onDecrement: {materialQuantity -= 1})
                TextField("Color", text: $itemDescription)
                Button("Add Material") {
                    try! publicRealm.write {
                        $project.materials.append(Material(type: materialType, itemDescription: itemDescription , quantity: materialQuantity))
                        alertTitle = "Success"
                        alertMessage = "\(materialType) added to job"
                        showingAlert = true
                    }
                }
                
            }
        }
        .onAppear(perform: initData)
        .alert(isPresented: $showingAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func getCrewName(memberId: String) -> String {
        let filteredMembers = crewMembers.filter(NSPredicate(format: "_id == %@", memberId))
        
        return filteredMembers.first?.displayName ?? "No Display Name"
        
    }
    
    func initData() {
        self.crew = project.assignedCrew ?? Crew()
    }
}

//struct JobView_Previews: PreviewProvider {
//    static var previews: some View {
//        JobView(job: Job())
//    }
//}
