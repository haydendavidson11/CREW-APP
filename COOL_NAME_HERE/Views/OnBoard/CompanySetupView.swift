//
//  CompanySetUpView.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 6/14/21.
//

import SwiftUI
import RealmSwift

struct CompanySetUpView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.realm) var publicRealm
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedResults(Company.self) var companies
    
    
    
    @State var administrators = [String]()
    @State var members = [String]()
    @State var companyName = ""
    @State var phone = ""
    @State var street = ""
    @State var city = ""
    @State var residentState = ""
    @State var zip = ""
    @State var country = ""
    @State var founded = ""
    @State var companyDescription = ""
    @State var isActive = false
    @State var photo: Photo?
    
    init() {
        UITextView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        VStack {
            ScrollView(.vertical) {
                VStack(spacing: 20) {
                    ZStack {
                        
                        Color(.secondarySystemBackground)
                            .frame(minHeight: 180)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    
                        VStack(alignment: .center, spacing: 4) {
                            
                            AvatarButton(photo: $photo, action: {})
                            
                            TextField("Business Name", text: $companyName)
                                .multilineTextAlignment(.center)
                                .minimumScaleFactor(0.50)
                                .lineLimit(1)
                                .padding(.horizontal)
                                .font(.system(size: 20, weight: .bold))
                            
                            TextField("Date Founded", text: $founded)
                                .multilineTextAlignment(.center)
                                .minimumScaleFactor(0.50)
                                .lineLimit(1)
                                .padding(.horizontal)
                                .font(.system(size: 12, weight: .bold))
                            
                        }
                        .padding(.horizontal)
                        
                    }
                    
                    VStack(spacing: 8) {
                        HStack {
                            Text("Business Description")
                                .bold()
                                .foregroundColor(.brandPrimary)
                                .font(.caption)
                                .padding(.horizontal)
                            Spacer()
                        }
                        
                        
                        TextEditor(text: $companyDescription)
                            .frame(minHeight: 100)
                            .padding(.horizontal, 5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8.0)
                                    .stroke(Color.secondary, lineWidth: 1)
                            )
                            .padding(.horizontal)
                            .padding(.bottom)
                        
                        
                        
                        VStack {
                            HStack {
                                Text("Business info")
                                    .bold()
                                    .foregroundColor(.brandPrimary)
                                    .font(.caption)
                                Spacer()
                            }
                            
                            HStack {
                                Image(systemName: "phone.fill")
                                    .foregroundColor(.brandPrimary)
                                TextField("Phone", text: $phone)
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
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    
                }
            }
            CallToActionButton(title: "Finish", action: {
                print("Finish Button Pushed")
                saveCompany()
                print("Company Saved")
                print(state.user?.companyID)
                state.loginPublisher.send(app.currentUser!)
                print("reload dashboard")
                
            })
                .padding()
                .environment(\.realmConfiguration,
                              app.currentUser!.configuration(partitionValue: "public=public"))
            
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Create Business")
        .accentColor(.brandPrimary)
    }
    
    func initData() {
        if let userID = state.user?._id {
            if administrators.isEmpty {
                administrators.append(userID)
            }
        }
    }
    
    func saveCompany() {
        var companyID = ""
        print(companies.count)
        
        try! publicRealm.write {
            
            let newAddress = Address()
            newAddress.street = street
            newAddress.city = city
            newAddress.state = residentState
            newAddress.zip = zip
            newAddress.country = country
            
            let newCompany = Company()
            
            newCompany.companyName = companyName
            newCompany.companyDescription = companyDescription
            newCompany.foundedDate = founded
            newCompany.phoneNumber = phone
            newCompany.address = newAddress
            
            newCompany.admins.append(state.user?._id ?? "")
            newCompany.founder = state.user?._id
            newCompany.partition = "public=public"
            
            newCompany.avatarImage = photo ?? Photo()
            companyID = newCompany._id
            
            $companies.append(newCompany)
            print("company added!")
            
        }
        updateUserCompany(companyID: companyID)
    }
    
    func updateUserCompany(companyID: String) {
        let userConfig =  app.currentUser!.configuration(partitionValue: "user=\(state.user?._id ?? "")")
        try! Realm(configuration: userConfig).write {
            state.user?.companyID = companyID
            state.user?.role = "Admin"
            print(state.user?.companyID)
        }
    }
}

struct CompanySetUpView_Previews: PreviewProvider {
    static var previews: some View {
        CompanySetUpView()
    }
}
