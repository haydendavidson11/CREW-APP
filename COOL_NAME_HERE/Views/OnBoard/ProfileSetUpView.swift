//
//  ProfileSetUpView.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 6/12/21.
//

import SwiftUI
import RealmSwift

struct ProfileSetupView: View {
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
    
    
    @State private var navigate = false
    @State private var shareContactInfo = false
    
    
    
    
    var characterCount: Int {
        let maxCount = 100
        let currentCount = maxCount - bio.count
        return currentCount
    }
    
    var body: some View {
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
                Toggle(isOn: $shareContactInfo) {
                    Text("Share contact info with others in your business?")
                } .toggleStyle(SwitchToggleStyle(tint: Color.brandPrimary))
                
                Spacer()
            }
            .padding(.horizontal)
            
            Spacer()
            
            if !state.setUpNewCompany {
                NavigationLink(destination: ConfirmCompanyView(userID: state.user!._id)
                                .environment(\.realmConfiguration,
                                              app.currentUser!.configuration(partitionValue: "public=public"))
                               , isActive: $navigate, label: {
                    
                    CallToActionButton(title: "Next",
                                       action: {
                        saveProfile()
                        navigate = true
                    })
                })
                    .padding(.horizontal)
            } else {
                NavigationLink(destination: CompanySetUpView()
                                .environment(\.realmConfiguration,
                                              app.currentUser!.configuration(partitionValue: "public=public"))
                               , isActive: $navigate, label: {
                    
                    CallToActionButton(title: "Next",
                                       action: {
                        saveProfile()
                        navigate = true
                    })
                        .disabled(displayName.isEmpty)
                    
                    
                })
                    .padding(.horizontal)
            }
            
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Create Profile")
        
        
    }
    
    func checkForRequest() -> Bool {
        let publicConfig =  app.currentUser!.configuration(partitionValue: "public=public")
        let realm = try! Realm(configuration: publicConfig)
        
        let requests = realm.objects(Request.self)
        print(requests.count)
        
        let request = requests.first(where: {$0.recipient == state.user?.userName})
        
        if request != nil {
            try! userRealm.write {
                print("user has pending request. updating company ID")
                state.user?.companyID = "Pending"
                
            }
            return true
        } else {
            return false
        }
    }
    
    private func saveProfile() {
        state.shouldIndicateActivity = true
        
        
        try! userRealm.write {
            
            if state.user?.userPreferences == nil {
                let availableMornings = AvailableDays()
                availableMornings.type = "Morning"
                
                let availableAfternoons = AvailableDays()
                availableAfternoons.type = "Afternoon"
                
                let availableFullDays = AvailableDays()
                availableFullDays.type = "FullDay"
                
                let preferences = UserPreferences()
                preferences.bio = bio
                preferences.displayName = displayName
                preferences.firstName = firstName
                preferences.lastName = lastName
                preferences.phoneNumber = phoneNumber
                preferences.shareContactInfo = shareContactInfo
                let newAddress = Address()
                newAddress.street = street
                newAddress.city = city
                newAddress.state = residentState
                newAddress.zip = zip
                newAddress.country = country
                preferences.address = newAddress
                
                preferences.availability.append(availableMornings)
                preferences.availability.append(availableAfternoons)
                preferences.availability.append(availableFullDays)
                //                    preferences.schedule.append(Shift())
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
            
        }
        state.shouldIndicateActivity = false
    }
}

//MARK: - Preview

struct ProfileSetupView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSetupView()
        
    }
}

//MARK: - BannerView

struct ProfileBannerView: View {
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var displayName: String
    
    @Binding var photo: Photo?
    
    var body: some View {
        ZStack {
            
            Color(.secondarySystemBackground)
                .frame(height: 130)
                .cornerRadius(12)
                .padding(.horizontal)
            
            HStack(spacing: 16) {
                
                AvatarButton(photo: $photo, action: {})
                    .padding(.leading)
                
                VStack(spacing: 1) {
                    TextField("First Name", text: $firstName)
                        .profileNameStyle()
                    
                    TextField("Last Name", text: $lastName)
                        .profileNameStyle()
                    
                    TextField("Display Name", text: $displayName)
                }
                .padding(.trailing, 16)
                
                Spacer()
            }
            .padding()
        }
    }
}



//MARK: - CharactersRemainView

struct CharactersRemainView: View {
    
    var characterCount: Int
    
    var body: some View {
        Text("Bio: ")
            .font(.callout)
            .foregroundColor(.secondary)
        +
        Text("\(characterCount) ")
            .foregroundColor(characterCount >= 0 ? .brandPrimary : .pink)
        +
        Text("characters remain")
            .font(.callout)
            .foregroundColor(.secondary)
    }
}

