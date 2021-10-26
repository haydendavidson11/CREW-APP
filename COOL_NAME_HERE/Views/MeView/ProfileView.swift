//
//  ProfileView.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 6/18/21.
//

import SwiftUI

import SwiftUI
import RealmSwift

struct ProfileView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.realm) var userRealm
    @Environment(\.presentationMode) var presentationMode
    
    @State private var displayName = ""
    @State private var bio = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var phoneNumber = ""
    @State private var street = ""
    @State private var city = ""
    @State private var zip = ""
    @State private var residentState = ""
    @State private var country = ""
    @State private var photo: Photo?
    @State private var company = Company()
    @State private var navigate = false
    @State private var alertPresented = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var shareContactInfo = false
    
    var hasCompany: Bool {
        return state.user?.companyID != nil
    }
    
    var characterCount: Int {
        let maxCount = 100
        let currentCount = maxCount - bio.count
        return currentCount
    }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 10) {
                ProfileBannerView(firstName: $firstName, lastName: $lastName, displayName: $displayName, photo: $photo)
                
                VStack(spacing: 8) {
                    HStack {
                        
                        CharactersRemainView(characterCount: characterCount)
                        
                        Spacer()
                        
                    }
                    .padding(.horizontal)
                    
                    TextEditor(text: $bio)
                        .frame(height: 100)
                        .padding(.horizontal, 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8.0)
                                .stroke(Color.secondary, lineWidth: 1)
                        )
                        .padding(.horizontal)
                }
                VStack {
                    HStack {
                        Text("Contact info")
                            .bold()
                            .foregroundColor(.brandPrimary)
                            .font(.caption)
                        Spacer()
                    }
                    
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.brandPrimary)
                        TextField("Phone", text: $phoneNumber)
                    }
                    
                    Divider()
                        .padding()
                    
                    HStack(alignment: .firstTextBaseline) {
                        Image(systemName: "location.fill")
                            .foregroundColor(.brandPrimary)
                        VStack {
                            TextField("Street", text: $street)
                            TextField("City", text: $city)
                            TextField("State", text: $residentState)
                            TextField("Zip", text: $zip)
                            TextField("Country", text: $country)
                        }
                    }
                    
                    Divider()
                        .padding()
                    
                    HStack {
                        Text("Share info")
                            .bold()
                            .foregroundColor(.brandPrimary)
                            .font(.caption)
                        Spacer()
                    }
    //                Spacer()
                    Toggle(isOn: $shareContactInfo) {
                        Text("Share contact info with others in your business?")
                            .minimumScaleFactor(0.75)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: Color.brandPrimary))
                }
                .padding(.horizontal)
                
                
                
                Spacer()
                
            }
            .alert(isPresented: $alertPresented) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .onAppear(perform: initData)
            .navigationBarItems(trailing: Button(action: {saveProfile()}, label: {
                Text("Save")
            }))
        }
    }
    
    private func saveProfile() {
        state.shouldIndicateActivity = true

        try! userRealm.write {
            if ((state.user?.userPreferences) == nil) {
                let preferences = UserPreferences()
                preferences.bio = bio
                preferences.displayName = displayName
                preferences.firstName = firstName
                preferences.lastName = lastName
                preferences.phoneNumber = phoneNumber
                let newAddress = Address()
                newAddress.street = street
                newAddress.city = city
                newAddress.state = residentState
                newAddress.zip = zip
                newAddress.country = country
                preferences.address = newAddress
                preferences.shareContactInfo = shareContactInfo
                state.user?.userPreferences = preferences
                
            } else {
                
                state.user?.userPreferences?.displayName = displayName
                state.user?.userPreferences?.firstName = firstName
                state.user?.userPreferences?.lastName = lastName
                state.user?.userPreferences?.phoneNumber = phoneNumber
                state.user?.userPreferences?.bio = bio
                state.user?.userPreferences?.shareContactInfo = shareContactInfo
                
                let newAddress = Address()
                newAddress.street = street
                newAddress.city = city
                newAddress.state = residentState
                newAddress.zip = zip
                newAddress.country = country
                state.user?.userPreferences?.address = newAddress
                
            }
            
            print("photo added")
            guard let newPhoto = photo else {
                print("Missing photo")
                state.shouldIndicateActivity = false
                return
            }
            state.user?.userPreferences?.avatarImage = newPhoto
            alertTitle = "Profile Saved"
            
        }
        state.shouldIndicateActivity = false
        alertPresented = true
    }
        
    private func initData() {
        displayName = state.user?.userPreferences?.displayName ?? ""
        photo = state.user?.userPreferences?.avatarImage
        firstName = state.user?.userPreferences?.firstName ?? ""
        lastName = state.user?.userPreferences?.lastName ?? ""
        phoneNumber = state.user?.userPreferences?.phoneNumber ?? ""
        street = state.user?.userPreferences?.address?.street ?? ""
        city = state.user?.userPreferences?.address?.city ?? ""
        residentState = state.user?.userPreferences?.address?.state ?? ""
        zip = state.user?.userPreferences?.address?.zip ?? ""
        country = state.user?.userPreferences?.address?.country ?? ""
        bio = state.user?.userPreferences?.bio ?? ""
        shareContactInfo = state.user?.userPreferences?.shareContactInfo ?? false
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
