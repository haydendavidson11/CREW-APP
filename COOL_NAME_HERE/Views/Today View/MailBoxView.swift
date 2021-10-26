//
//  MailBoxView.swift
//  MailBoxView
//
//  Created by Hayden Davidson on 9/15/21.
//

import SwiftUI
import RealmSwift
import UserNotifications


struct MailBoxView: View {
    @EnvironmentObject var state: AppState
    @ObservedResults(Request.self) var requests
    
    @State var labelNumber = 0
    
    @State var notificationToken: NotificationToken?
    
    var body: some View {
        ZStack {
            
            Image(systemName: "envelope")
                .foregroundColor(.brandPrimary)
                .overlay(labelNumber > 0  ? NotificationNumLabel(digit: $labelNumber).position(x: 20, y: 0): nil)//digit: $labelNumber
        }
        .onAppear(perform: getNewRequests)
        .onChange(of: notificationToken) { newValue in
            getUserRequests()
        }
        
    }
    
    func getUserRequests() {
        let userRequests = requests.filter(NSPredicate(format: "recipient == %@", state.user?.userName  ?? ""))
        let pendingRequest = userRequests.filter(NSPredicate(format: "status == %@", "pending"))
        if pendingRequest.count > 0 {
            labelNumber = pendingRequest.count
        } else {
            labelNumber = 0
        }


    }
    
    func getNewRequests() {
        print("getting new requests")
        let publicConfig =  app.currentUser!.configuration(partitionValue: "public=public")
        let realm = try! Realm(configuration: publicConfig)
        let requests = realm.objects(Request.self).filter(NSPredicate(format: "recipient == %@", state.user?.userName ?? ""))
        let pendingRequests = requests.filter(NSPredicate(format: "status == %@", "pending"))
        labelNumber = pendingRequests.count
        print("user has \(requests.count) requests")
        
        
        
        
        notificationToken = requests.observe { (changes: RealmCollectionChange) in
                    
                    switch changes {
                    case .initial:
                        // Results are now populated and can be accessed without blocking the UI
                        print("have initial requests")
                        if labelNumber == 0 {
                            getUserRequests()
                        }
                        print(changes)
                    case .update(_, let deletions, let insertions, let modifications):
                        // Query results have changed, so apply them to the UITableView
                        print(changes)
                        //Deletions
                        print("deletions: \(deletions.count)")
                        if deletions.count > 0 {
                            getUserRequests()
                        }
                        
                        //Insertions
                        print("insertions: \(insertions.count)")
                        if insertions.count > 0 {
                            getUserRequests()
                        }
                        
                        
                        print("modifications: \(modifications.count)")
                        //Modifications
                        if modifications.count > 0 {
                            getUserRequests()
                        }
                            // Always apply updates in the following order: deletions, insertions, then modifications.
                            // Handling insertions before deletions may result in unexpected behavior.
                            
                    case .error(let error):
                        // An error occurred while opening the Realm file on the background worker thread
                        fatalError("\(error)")
                    }
                }
    }
}


struct NotificationNumLabel : View {
    @Binding var digit : Int
    
    var body: some View {
        ZStack {
            Capsule().fill(Color.red
                            .opacity(0.9))
                .overlay(Text("\(digit)")
                            .minimumScaleFactor(0.5)
                            .foregroundColor(Color.white))
        }
    }
    
    func numOfDigits() -> Float {
        let numOfDigits = Float(String(digit).count)
        return numOfDigits == 1 ? 1.5 : numOfDigits
    }
}

//struct MailBoxView_Previews: PreviewProvider {
//    static var previews: some View {
//        MailBoxView()
//    }
//}
