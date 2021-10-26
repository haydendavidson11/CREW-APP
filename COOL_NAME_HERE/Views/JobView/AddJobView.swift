//
//  AddJobView.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 3/30/21.
//

import SwiftUI
import RealmSwift

struct AddJobView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.realm) var publicRealm
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedResults(Project.self) var projects
    @ObservedResults(Client.self) var clients
    
    @State private var name = ""
    @State private var isActiveJob = ["Active", "Complete"]
    @State private var jobStatus = 0
    @State private var showingAddAlert = false
    @State private var addAlertMessage = ""
    @State private var addAlertTitle = ""
    @State private var jobStartDate = Date()
    @State private var jobCompletionDate = Date()
    @State private var street = ""
    @State private var city = ""
    @State private var zip = ""
    @State private var residentState = ""
    @State private var country = ""
    @State private var gateCode = ""
    @State private var client = Client()
    @State private var clientSet = false
    @State private var useClientAddress = false
    
    var forClient: Client?
    
    
    var body: some View {
        
        NavigationView {
            Form {
                Section(header: Text("Job Name")) {
                    TextField("Name", text: $name)
                }
                
                Section(header: Text("Client")) {
                    if forClient != nil {
                        Text("\(forClient!.firstName) \(forClient!.lastName)")
                    } else {
                        Picker(client.firstName.isEmpty ? "Select Client" : "\(client.firstName) \(client.lastName)", selection: $client) {
                            ForEach(clients.sorted(byKeyPath: "firstName", ascending: true), id: \._id) { client in
                                Text("\(client.firstName) \(client.lastName)").tag(client)
                            }
                        }
                    }
                }
                HStack {
                    Spacer()
                    Picker("Is Active", selection: $jobStatus) {
                        ForEach(0..<isActiveJob.count) {
                            Text(isActiveJob[$0])
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    Spacer()
                }
                
                DatePicker("Start Date", selection: $jobStartDate, displayedComponents: .date)
                DatePicker("Start Time", selection: $jobStartDate, displayedComponents: .hourAndMinute)
                if jobStatus == 1 {
                    DatePicker("Completion Date", selection: $jobCompletionDate, displayedComponents: .date)
                }
                
                HStack {
                    Toggle("Use Client Address", isOn: $useClientAddress)
                }
                
                if useClientAddress {
//                    if forClient != nil {
//                        Section(header: Text("Address")) {
//                            Text(forClient?.address?.street ?? "")
//                            Text(forClient?.address?.city ?? "")
//                            Text(forClient?.address?.state ?? "")
//                            Text(forClient?.address?.zip ?? "")
//                            Text(forClient?.address?.country ?? "")
//                        }
//                    } else {
                        Section(header: Text("Address")) {
                            Text(client.address?.street ?? "")
                            Text(client.address?.city ?? "")
                            Text(client.address?.state ?? "")
                            Text(client.address?.zip ?? "")
                            Text(client.address?.country ?? "")
                        }
//                    }
                } else {
                    Section(header: Text("Address")) {
                        TextField("Street", text: $street)
                        TextField("City", text: $city)
                        TextField("State", text: $residentState)
                        TextField("Zip", text: $zip)
                        TextField("Country", text: $country)
                        TextField("Gate Code", text: $gateCode)
                    }
                }
                CallToActionButton(title: "Save", action: { addJob() })
            }
            .navigationTitle("Add Job")
            .alert(isPresented: $showingAddAlert, content: {
                Alert(title: Text(addAlertTitle), message: Text(addAlertMessage), dismissButton: .default(Text("OK"), action: {
                    presentationMode.wrappedValue.dismiss()
                }))
            })
        }
        .padding(.bottom)
        .accentColor(.brandPrimary)
        .onAppear {
            if forClient != nil {
                self.client = forClient!
            }
        }
        
    }
    
    func addJob() {
        state.shouldIndicateActivity = true
        let newAddress = Address()
        newAddress.street = street
        newAddress.city = city
        newAddress.state = residentState
        newAddress.zip = zip
        newAddress.country = country
        if !gateCode.isEmpty {
            newAddress.gateCode = gateCode
        }
        
        let clientAddress = Address()
        clientAddress.street = client.address?.street
        clientAddress.city = client.address?.city
        clientAddress.state = client.address?.state
        clientAddress.zip = client.address?.zip
        clientAddress.country = client.address?.country
        clientAddress.gateCode = client.address?.gateCode
        
        let newJob = Project()
        newJob.name = name
        newJob.client = "\(client.firstName) \(client.lastName)"
        
        newJob.startDate = jobStartDate
        newJob.isActive = isActiveJob[jobStatus]
        newJob.startTime = Date()
        newJob.address = useClientAddress ? clientAddress : newAddress
        newJob.partition = "public=\(state.user?.companyID ?? "")"
        
        $projects.append(newJob)
        
        
        
        addAlertTitle = "Success"
        
        state.shouldIndicateActivity = false
        showingAddAlert = true
        
    }
}

//struct AddJobView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddJobView()
//    }
//}
