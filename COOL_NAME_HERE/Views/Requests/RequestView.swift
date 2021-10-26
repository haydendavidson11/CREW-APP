//
//  RequestView.swift
//  RequestView
//
//  Created by Hayden Davidson on 8/11/21.
//

import SwiftUI
import RealmSwift

struct RequestView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.realm) var publicRealm
    @ObservedResults(CrewMember.self) var crewMembers
    @ObservedResults(Company.self) var companies
    @ObservedResults(Request.self) var requests
    
    @ObservedRealmObject var request: Request
    
   

    
    var body: some View {
        if request.type == "join" || request.type == "invite" {
            JoinCompanyRequestView(request: request)
        } else if request.type == "shift" {
            ShiftRequestView(request: request)
        } else {
            RoleChangeRequestView(request: request)
        }
    }
    
    
    // Changes the observed request's status to "accepted"
    func acceptRequest(for: Request) {
        try! publicRealm.write {
            request.thaw()?.requestState = .accepted
        }
    }
    
    // Changes the observed request's status to "pending"
    func setRequestToPending(for: Request) {
        try! publicRealm.write {
            request.thaw()?.requestState = .pending
    
        }
    }
    // Changes the observed request's status to "denied"
    func denyRequest(for: Request) {
        try! publicRealm.write {
            request.thaw()?.requestState = .denied
        }
    }
}
