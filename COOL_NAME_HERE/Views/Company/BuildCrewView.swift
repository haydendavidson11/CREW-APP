//
//  BuildCrewView.swift
//  BuildCrewView
//
//  Created by Hayden Davidson on 8/13/21.
//

import SwiftUI
import RealmSwift

struct BuildCrewView: View {
    
    @EnvironmentObject var state: AppState
    @Environment(\.realm) var publicRealm
    
    
    @ObservedResults(CrewMember.self) var crewMembers
    @ObservedRealmObject var company: Company
    
    let columns = [GridItem(.flexible()),
                   GridItem(.flexible()),
                   GridItem(.flexible())]
    
    @State private var crew = [CrewMember]()
    @State private var crewName = ""
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    //    var date: Date?
    
    var filteredCrewMembers : Results<CrewMember> {
        guard let userCompany = state.user?.companyID else { return crewMembers }
        
        return crewMembers.filter(NSPredicate(format: "companyID == %@", userCompany))
    }
    
    
    var body: some View {
        VStack {
            Text("Build Your Crew")
                .font(.title)
            if crew.isEmpty {
                Text("Select from the people below")
                    .font(.caption)
            }
            if crew.count > 0 {
                VStack {
                    TextField("Crew Name", text: $crewName)
                        .multilineTextAlignment(.center)
                    
                    LazyVGrid(columns: columns) {
                        ForEach(crew) { person in
                            VStack {
                                AvatarThumbNailView(photo: person.avatarImage ?? Photo(), imageSize: 80)
                                Text(person.displayName ?? "")
                                    .minimumScaleFactor(0.75)
                                    .font(.caption)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground)
                                .cornerRadius(12)
                                .padding(.horizontal))
                
                Divider()
                    .padding()
                
                Text("Crew Members")
                
            }
            
            
            LazyVGrid(columns: columns) {
                
                ForEach(filteredCrewMembers) { crewMember in
                    VStack {
                        AvatarThumbNailView(photo: crewMember.avatarImage ?? Photo(), imageSize: 80)
                        Text(crewMember.displayName ?? "")
                            .minimumScaleFactor(0.75)
                            .font(.caption)
                    }
                        .onTapGesture {
                            addOrRemoveCrewMember(crewMember)
                        }
                }
            }
            .padding()
           
        }
        .alert(isPresented: $showingAlert, content: {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        })
        .navigationBarItems(trailing: Button(action: {
            saveCrew()
        }, label: {
            Text("Save")
        }))
    }
    
    func addOrRemoveCrewMember(_ crewMember: CrewMember) {
        if crew.contains(crewMember), let pos = crew.firstIndex(of: crewMember) {
            crew.remove(at: pos)
        } else {
            crew.append(crewMember)
        }
    }
    
    func saveCrew() {
        
        print("saving crew to company")
        print(crewName)
        let newCrew = Crew()
        newCrew.name = crewName
        
        for member in crew {
            newCrew.members.append(member._id)
        }
        
        do {
            try publicRealm.write {
                company.thaw()?.crews.append(newCrew)
            }
            alertTitle = "Success"
            alertMessage = "Crew Saved!"
        } catch {
            alertTitle = "Sorry!"
            alertMessage = "Could not save company. Try again."
        }
        
        showingAlert = true
        
        
    }
}

//struct BuildCrewView_Previews: PreviewProvider {
//    static var previews: some View {
//        BuildCrewView()
//    }
//}
