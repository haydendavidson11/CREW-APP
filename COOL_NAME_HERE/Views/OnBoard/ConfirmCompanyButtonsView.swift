//
//  SetCompanyView.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 6/17/21.
//

import SwiftUI

struct ConfirmCompanyButtonsView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.realm) var userRealm
    @Environment(\.presentationMode) var presentationMode
    @State private var navigate = false
    var companyID: String
    
    var body: some View {
        
        VStack(spacing: 12) {
            NavigationButton(title: "Yup!", action: {
                try! userRealm.write {
                    state.user?.companyID = companyID
                }
            }, destination: AnyView(ContentView()))
                .padding(.horizontal)
            NavigationLink(destination: CompanySetUpView(), isActive: $navigate) {
                CallToActionButton(title: "Nope") {
                    self.navigate.toggle()
                }
            }
            .padding(.horizontal)
        }
    }
}

struct SetCompanyView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmCompanyButtonsView(companyID: UUID().uuidString)
    }
}
