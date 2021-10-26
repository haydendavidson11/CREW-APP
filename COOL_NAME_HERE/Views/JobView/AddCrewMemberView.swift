//
//  AddCrewMemberView.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 6/24/21.
//

import SwiftUI
import RealmSwift

struct AddCrewMemberView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.realm) var publicRealm
    
    @ObservedRealmObject var project: Project
    @ObservedResults(CrewMember.self) var crewMembers
    
    @State private var showingAlert = false
    @State private var showingActionSheet = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var crew: Crew?
    
    @State var crewMember = CrewMember() {
        didSet {
            print("set crewMember to \(crewMember.displayName ?? "")")
        }
    }
    
    var companyCrewMembers: Results<CrewMember> {
        return crewMembers.filter(NSPredicate(format: "companyID == %@", state.user?.companyID ?? ""))
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(companyCrewMembers, id: \.id) { member in
                    HStack {
                        AvatarThumbNailView(photo: member.avatarImage ?? Photo(), imageSize: 30)
                        
                        Text(member.displayName ?? "")
                    }
                    .onTapGesture {
                        self.crewMember = member
                        alertTitle = "Add Crew Member"
                        alertMessage = crewMember.displayName ?? ""
                        showingActionSheet = true
                    }
                    .alert(isPresented: $showingAlert, content: {
                        Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                    })
                }
                
            }
            .actionSheet(isPresented: $showingActionSheet, content: {
                ActionSheet(title: Text(alertTitle), message: Text(alertMessage), buttons: [.default(Text("OK"), action: {addCrewMember()}), .cancel()])
            })
            
            .navigationTitle("Crew Members")
            .navigationBarItems(trailing: Button(action: {presentationMode.wrappedValue.dismiss()}, label: {
                Text("Done")
            }))
            .accentColor(.brandPrimary)
        }
    }
    
    func addCrewMember() {
        
        if !project.crew.contains(crewMember._id) {
            $project.crew.append(crewMember._id)
            print("crew member added")
            
            let companyConfig =  app.currentUser!.configuration(partitionValue: "public=\(state.user?.companyID ?? "")")
            
            try! Realm(configuration: companyConfig).write {
                let formatter = DateFormatter()
                
                formatter.timeStyle = .short
                formatter.dateStyle = .short
                
                let dateString = formatter.string(from: Date())
                
                let newEvent = Event()
                if let crewMember = crewMembers.first(where: {$0._id == state.user?._id}) {
                    newEvent.userAvatar = Photo()
                    newEvent.userAvatar?.thumbNail = crewMember.avatarImage?.thumbNail
                    newEvent.userAvatar?.picture = crewMember.avatarImage?.picture
                    newEvent.userAvatar?._id = crewMember.avatarImage?._id ?? ""
                    newEvent.userAvatar?.date = crewMember.avatarImage?.date ?? Date()
                }
                newEvent.date = dateString
                newEvent.typeState = .crewMemberAdded
                newEvent.info = "\(crewMember.displayName ?? "") added to crew"
                
                project.thaw()?.activity.insert(newEvent, at: 0)
            }
        } else {
            print("crew member already exists")
            alertTitle = "oops!"
            alertMessage = "\(crewMember.displayName ?? "Crew Member") is already a member of this crew"
            showingAlert = true
        }
    }
}

//struct AddCrewMemberView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddCrewMemberView()
//    }
//}
