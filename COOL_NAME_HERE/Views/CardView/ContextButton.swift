//
//  ContextButton.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 5/10/21.
//

import SwiftUI
import RealmSwift

struct ContextButton: View {
    @EnvironmentObject var state: AppState
    @Environment(\.realm) var publicRealm
    
    @ObservedRealmObject var project: Project
    
    var label: String
    var category: Category
    
    var body: some View {
        
        Button {
            writeChanges()
        } label: {
            Text(label)
                .minimumScaleFactor(0.50)
        }
    }
    
    func writeChanges() {
        let newEvent = Event()
        
        let publicConfig =  app.currentUser!.configuration(partitionValue: "public=public")
        let realm = try! Realm(configuration: publicConfig)
        
        let crewMembers = realm.objects(CrewMember.self)
        
        if let crewMember = crewMembers.first(where: {$0._id == state.user?._id}) {
            newEvent.userAvatar = Photo()
            newEvent.userAvatar?.thumbNail = crewMember.avatarImage?.thumbNail
            newEvent.userAvatar?.picture = crewMember.avatarImage?.picture
            newEvent.userAvatar?._id = crewMember.avatarImage?._id ?? ""
            newEvent.userAvatar?.date = crewMember.avatarImage?.date ?? Date()
        }
        
        try! publicRealm.write {
            
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            formatter.dateStyle = .short
            let dateString = formatter.string(from: Date())
            
            newEvent.typeState = .categoryChanged
            newEvent.info = "Updated from \(project.category) to \(label)"
            newEvent.date =  dateString
            
            if category == .complete {
                project.thaw()?.completionDate = Date()
            }
            project.thaw()?.categoryState = category
            project.thaw()?.activity.insert(newEvent, at: 0)
        }
    }
}

//struct ContextButton_Previews: PreviewProvider {
//    static var previews: some View {
//        ContextButton()
//    }
//}
