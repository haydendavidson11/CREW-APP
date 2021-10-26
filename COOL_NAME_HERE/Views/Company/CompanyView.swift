//
//  CompanySetUpView.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 6/14/21.
//

import SwiftUI
import RealmSwift

struct CompanyView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.realm) var publicRealm
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedResults(Company.self) var companies
    
    
    var company: Company {
        let userCompanies =  companies.filter(NSPredicate(format: "_id == %@", state.user?.companyID ?? ""))
        return userCompanies.first ?? Company()
    }
    
    init() {
        UITextView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        NavigationView {
            VStack {
                
                AvatarThumbNailView(photo: company.avatarImage ?? Photo(), imageSize: 100)
                Text(company.companyName)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .disabled(state.user?._id == company.founder)
                
                List {
                    
                    NavigationLink {
                        CompanyDataView(company: companies.first(where: { company in
                            company.members.contains(state.user?._id ?? "") || company.admins.contains(state.user?._id ?? "")
                        }) ?? Company() )
                            .environment(\.realmConfiguration,
                                          app.currentUser!.configuration(partitionValue: "public=public"))
                    } label: {
                        Label("Business Info", systemImage: "info.circle")
                            .font(.headline)
                        
                    }
                    
                    NavigationLink(destination: CompanyPeopleView(company: company)) {
                        Label("People", systemImage: "person.circle")
                            .font(.headline)
                    }
                    
                    if company.isAdmin(userID: state.user?._id ?? "") || company.isManager(userID: state.user?._id ?? "") {
                        
                        NavigationLink(destination: CompanyRequestsView(company: company)
                                        .environment(\.realmConfiguration,
                                                      app.currentUser!.configuration(partitionValue: "public=public"))) {
                            Label("Requests", systemImage: "envelope.circle")
                                .font(.headline)
                        }
                        
                        NavigationLink(destination: BuildCompanySchedule()) {
                            Label("Schedule", systemImage: "calendar.circle")
                                .font(.headline)
                        }
                        
                        NavigationLink(destination: BusinessCrewsView(company: company)
                                        .environment(\.realmConfiguration,
                                                      app.currentUser!.configuration(partitionValue: "public=public"))) {
                            Label("Crews", systemImage: "person.2.circle")
                                .font(.headline)
                        }
                        
                        NavigationLink(destination: CompanyMaterialsList()) {
                            Label("Materials", systemImage: "barcode.viewfinder")
                                .font(.headline)
                        }
                    }
                    
                    
                }
                .listSectionSeparator(.hidden)
                
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .accentColor(.brandPrimary)
        }
    }
}

struct CompanyView_Previews: PreviewProvider {
    static var previews: some View {
        CompanyView()
    }
}

struct CompanyDataView: View {
    
    @EnvironmentObject var state: AppState
    @Environment(\.realm) var publicRealm
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedRealmObject var company: Company
    
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
    @State var showingAlert = false
    
    
    
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
                            
                            TextField("Company", text: $companyName)
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
                            Text("Company Description")
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
                                Text("Company info")
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
            .navigationBarItems(trailing: state.user?._id == company.founder ? Button("Save") {
                saveCompany()
            } : nil)
        }
        .refreshable {
            initData()
        }
        .alert(isPresented: $showingAlert, content: {
            Alert(title: Text("Success"), message: Text("Company info saved"), dismissButton: .default(Text("OK")))
        })
        .onAppear(perform: initData)
        
    }
    
    func saveCompany() {
        try! publicRealm.write {
            
            company.thaw()?.companyName = companyName
            company.thaw()?.companyDescription = companyDescription
            company.thaw()?.foundedDate = founded
            company.thaw()?.phoneNumber = phone
            company.thaw()?.address?.street = street
            company.thaw()?.address?.city = city
            company.thaw()?.address?.state = residentState
            company.thaw()?.address?.zip = zip
            company.thaw()?.address?.country = country
            
            if photo == company.avatarImage {
                print("company photo was not updated or changed")
            } else {
                guard let newPhoto = photo else {
                    print("Missing photo")
                    state.shouldIndicateActivity = false
                    return
                }
                company.thaw()?.avatarImage?.picture = newPhoto.picture
                company.thaw()?.avatarImage?.thumbNail = newPhoto.thumbNail
                company.thaw()?.avatarImage?.date = newPhoto.date
            }
            
            
        }
        self.showingAlert = true
        
    }
    
    func  initData() {
        if company.avatarImage != nil {
            photo = company.avatarImage
        }
        
        companyName = company.companyName
        companyDescription = company.companyDescription
        founded = company.foundedDate ?? ""
        phone = company.phoneNumber ?? ""
        street = company.address?.street ?? ""
        city = company.address?.city ?? ""
        residentState = company.address?.state ?? ""
        zip = company.address?.zip ?? ""
        country = company.address?.country ?? ""
    }
}
