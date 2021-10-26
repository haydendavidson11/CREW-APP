//
//  NoticifationHelper.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 10/2/21.
//

import Foundation
import UIKit
import RealmSwift
import UserNotifications


class NotificationHelper: ObservableObject {
    
    @Published var newRequests = 0
    
    
    var notificationToken: NotificationToken?
    
    
//    func getPermission() {
//        UNUserNotificationCenter.current()
//            .requestAuthorization(options: [.alert, .badge , .sound]) { success, error in
//            if success {
//                print("have permission to send notifications!")
////                guard settings.authorizationStatus == .authorized else { return }
////                DispatchQueue.main.async {
////                  UIApplication.shared.registerForRemoteNotifications()
////                }
//
//
//
//            } else if let error = error  {
//                print(error.localizedDescription)
//            }
//        }
//    }
    
//    func buildNotification(title: String, subtitle: String?, request: Request) {
//        var components =  Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: request.dateCreated)
//
//        let content = UNMutableNotificationContent()
//        if let minutes = components.minute {
//            components.setValue(minutes + 1, for: .minute)
//        }
//        content.title = title
//        if let subtitle = subtitle {
//            content.subtitle = subtitle
//        }
//        content.sound = UNNotificationSound.default
//
//        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
////        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//
//        let request = UNNotificationRequest(identifier: request._id, content: content, trigger: trigger)
////        print("adding Notification")
//        let center = UNUserNotificationCenter.current()
//        center.getPendingNotificationRequests { requests in
//            if !requests.contains(request) {
//                print("adding Notification")
//                center.add(request)
//            }
//        }
//
//
//    }
    
    func getNewRequests(user: User) {
        print("getting new requests")
        let publicConfig =  app.currentUser!.configuration(partitionValue: "public=public")
        let realm = try! Realm(configuration: publicConfig)
        let requests = realm.objects(Request.self).filter(NSPredicate(format: "recipient == %@", user.userName))
        print("user has \(requests.count) requests")
        
        
        
        
        notificationToken = requests.observe { (changes: RealmCollectionChange) in
                    
                    switch changes {
                    case .initial:
                        // Results are now populated and can be accessed without blocking the UI
                        print("have initial requests")
                        print(changes)
                    case .update(_, let deletions, let insertions, let modifications):
                        // Query results have changed, so apply them to the UITableView
                        print(changes)
                        print("deletions: \(deletions.count)")
                        
                        
                        print("insertions: \(insertions.count)")
                        for i in insertions {
                            let request = requests[i]
                            switch request.status {
                            case "pending":
                                print("Building Notifications")
//                                self.buildNotification(title: "You have a new \(request.type) request", subtitle: "Open for details.", request: request)
                                self.newRequests += 1
                            case "accepted":
                                print("request has been accepted")
                            default :
                                print("request was denied")
                            }
                            
                        }
                        
                        
                        print("modifications: \(modifications.count)")
                            // Always apply updates in the following order: deletions, insertions, then modifications.
                            // Handling insertions before deletions may result in unexpected behavior.
                            
                    case .error(let error):
                        // An error occurred while opening the Realm file on the background worker thread
                        fatalError("\(error)")
                    }
                }
    }
    
    
}
