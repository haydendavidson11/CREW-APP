//
//  Cool_Name_Here-App.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 4/12/21.
//

import SwiftUI
import RealmSwift

let app = RealmSwift.App(id: "cool_name_here-cncln")

@main
struct Cool_Name_Here_app: SwiftUI.App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject var state = AppState()
//    var notificationHelper = NotificationHelper()
    var calendarHelper = CalendarHelper()
    
    var body: some Scene {
        WindowGroup {
            if state.isFirstLaunch && state.user == nil {
                ZStack {
                    VStack{
                        OnBoardView()
                            .environmentObject(state)
                            .environmentObject(calendarHelper)
                            .accentColor(.brandPrimary)
                        if let error = state.error {
                            if error == "confirmation required" {
                                Text("A confirmation email was sent to you, please click on the link to confirm your account. Once confirmed return and login.")
                                    .multilineTextAlignment(.center)
                            } else {
                                Text("\(error)")
                                    .foregroundColor(Color.red)
                            }
                        }
                    }

                    if state.shouldIndicateActivity {
                        ProgressView("Fetching your info")
                    }
                }
                .onAppear(perform: {
                    calendarHelper.requestPermission()
                })
                .currentDeviceNavigationViewStyle(alwaysStacked: true)
                
            } else {
                ZStack {
                    VStack {
                        ContentView()
                            .environmentObject(state)
                            .environmentObject(calendarHelper)
                        
                        if let error = state.error {
                            if error == "confirmation required" {
                                Text("A confirmation email was sent to you, please click on the link to confirm your account. Once confirmed return and login.")
                                    .multilineTextAlignment(.center)
                                    .padding()
                            } else {
                            Text("\(error)")
                                .foregroundColor(Color.red)
                                .multilineTextAlignment(.center)
                                .padding()
                            }
                        }
                    }
                    
                    if state.shouldIndicateActivity {
                        ProgressView("Fetching your info")
                    }
                }
                .onAppear(perform: {
                    calendarHelper.requestPermission()
                })
                .onAppear(perform: {UserDefaults.standard.set(true, forKey: "didLaunchBefore")})
                .currentDeviceNavigationViewStyle(alwaysStacked: true)
            }
        }
        
    }
}
