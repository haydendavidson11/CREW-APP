//
//  BusinessCrewsView.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 9/27/21.
//

import SwiftUI
import RealmSwift

struct BusinessCrewsView: View {
    @EnvironmentObject var  state: AppState
    
    
    @State private var crews = [Crew]()
    
    
    @ObservedRealmObject var company: Company
    
    
    var body: some View {
        VStack {
            if company.crews.count > 0 {
                List {
                    ForEach(company.crews, id: \.self) { crew in
                        CrewView(crew: crew)
                    }
                    .onDelete(perform: $company.crews.remove)
                }
            } else {
                Text("Create a new crew by pressing the + in the top right corner.")
                    .padding()
            }
        }
        .navigationBarItems(trailing: NavigationLink(destination: {
            BuildCrewView(company: company)
        }, label: {
            Image(systemName: "plus")
                .foregroundColor(.brandPrimary)
        }))
        .navigationTitle("Crews")
        .navigationBarTitleDisplayMode(.inline)
    }
}

//struct BusinessCrewsView_Previews: PreviewProvider {
//    static var previews: some View {
//        BusinessCrewsView()
//    }
//}

struct CrewView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.realm) var publicRealm
    
    @ObservedResults(CrewMember.self) var crewMembers
    
    var crew: Crew
    var date: Date?
    
    @State private var members = [CrewMember]()
    @State private var showingSendShiftRequest = false

    var body: some View {
        HStack {
            Text("\(crew.name ?? "")")
            Spacer()
                ForEach(members, id: \._id) { member in
                    AvatarThumbNailView(photo: member.avatarImage ?? Photo(), imageSize: 40)
                }
            if date != nil {
            Image(systemName: "chevron.right")
                .foregroundColor(.brandPrimary)
            }
            
        }
        .onTapGesture {
            if date != nil {
                showingSendShiftRequest = true
            }
        }
        .onAppear {
            getCrewMembers()
        }
        .sheet(isPresented: $showingSendShiftRequest) {
            SendShiftRequestView(crew: members, crewName: crew.name, date: date ?? Date())
        }
    }
    
    func getCrewMembers() {
        for member in crewMembers {
            if crew.members.contains(member._id) && !members.contains(member) {
                members.append(member)
            }
        }
    }
    
}
