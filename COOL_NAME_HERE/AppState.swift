//
//  AppState.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 4/12/21.
//


import RealmSwift
import SwiftUI
import Combine


class AppState: ObservableObject {
//    let notificationHelper = NotificationHelper()
  
    @Published var error: String? {
        didSet {
            if error == "confirmation required" {
                confirmationSent = true
            }
        }
    }
    @Published var busyCount = 0
    @Published var companySet = false
    @Published var shiftTypeColor = Color.brandPrimary
    @Published var confirmationSent = false
    @Published var NewUserRequest = 0
    
    var setUpNewCompany = false

    // Checks if this is the first time running the app.
    var isFirstLaunch: Bool {
       return !UserDefaults.standard.bool(forKey: "didLaunchBefore")
    }
    
    // Combine publisher for when the user logs into MongoDB Realm
    var loginPublisher = PassthroughSubject<RealmSwift.User, Error>()
    
    // Combine publisher for when the user logs out of MongoDB Realm
    var logoutPublisher = PassthroughSubject<Void, Error>()
    
    // Combine publisher for when we receive the user from the MongoDB Realm
    var userRealmPublisher = PassthroughSubject<Realm, Error>()
    
    var cancellables = Set<AnyCancellable>()

    
    // This displays a progress view over any screen that is presented.
    var shouldIndicateActivity: Bool {
        get {
            return busyCount > 0
        }
        set (newState) {
            if newState {
                busyCount += 1
            } else {
                if busyCount > 0 {
                    busyCount -= 1
                } else {
                    print("Attempted to decrement busyCount below 1")
                }
            }
        }
    }
    
    
    // Set to true when the user's company ID is set.
    var userHasCompany: Bool {
        get {
            if user?.companyID != nil && user?.companyID != "" && user?.companyID != "pending" {

                return true
            } else {
                return false
            }
        }
        set (newState) {
            if newState {
                companySet = true
            } else {
                companySet = false
            }
        }

    }
    
    
    // Permission for Admins
    var canEditAndDelete: Bool {
        if user?.role == "Admin" {
            return true
        } else {
            return false
        }
    }
    
    
    // Permission for Managers
    var canAddClient: Bool {
        if user?.role == "Admin" || user?.role == "Manager" {
            return true
        } else {
            return false
        }
    }
    

    // The Current Realm User
    var user: User? {
        didSet {
            print("User set")
          
            
            let calendarModel = MDPModel()
            calendarModel.user = user
            if let user = user {
//                notificationHelper.getNewRequests(user: user)
                print("have user")
                
                print("have app delegate")
                let userConfig =  app.currentUser!.configuration(partitionValue: "user=\(user._id)")
                try! Realm(configuration: userConfig).write {
                    user.deviceToken = AppDelegate.instance.token
                }
            }
            
        }
    }

    // checks if the user is logged into MongoDB Realm
    var loggedIn: Bool {
        app.currentUser != nil && user != nil && app.currentUser?.state == .loggedIn
    }

    init() {
        _  = app.currentUser?.logOut()
        initLoginPublisher()
        initUserRealmPublisher()
        initLogoutPublisher()

    }

    
    
    func initLoginPublisher() {
        loginPublisher
            .receive(on: DispatchQueue.main)
            .flatMap { user -> RealmPublishers.AsyncOpenPublisher in
                self.shouldIndicateActivity = true
                let realmConfig = user.configuration(partitionValue: "user=\(user.id)")
                print(user.id)
                print(realmConfig)
                return Realm.asyncOpen(configuration: realmConfig)
            }
            .receive(on: DispatchQueue.main)
            .map {
                return $0
            }
            .subscribe(userRealmPublisher)
            .store(in: &self.cancellables)
    }
    
    func initUserRealmPublisher() {
        userRealmPublisher
            .print()
            .sink(receiveCompletion: { result in
                if case let .failure(error) = result {
                    self.error = "Failed to log in and open user realm: \(error.localizedDescription)"
                }
            }, receiveValue: { realm in
                print("User Realm User file location: \(realm.configuration.fileURL!.path)")
                self.user = realm.objects(User.self).first
                self.shouldIndicateActivity = false
            })
            .store(in: &cancellables)
    }
    
    func initLogoutPublisher() {
        logoutPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { _ in
                self.user = nil
            })
            .store(in: &cancellables)
    }
}
