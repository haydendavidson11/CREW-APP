//
//  AddJobView.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 3/30/21.
//

import SwiftUI
import RealmSwift

struct AddClientView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var state: AppState
    
    @ObservedResults(Client.self) var clients
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var street = ""
    @State private var city = ""
    @State private var zip = ""
    @State private var residentState = ""
    @State private var country = "USA"
    @State private var gateCode = ""
    @State private var showingAddAlert = false
    @State private var addAlertMessage = ""
    @State private var addAlertTitle = ""
    
    var addButtonDisabled: Bool {
        if firstName.isEmpty || lastName.isEmpty || email.isEmpty || phone.isEmpty || street.isEmpty || city.isEmpty || zip.isEmpty || residentState.isEmpty || country.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    var body: some View {
        
        NavigationView {
            Form {
                Section(header: Text("Client")) {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                    TextField("Phone", text: $phone)
                        .keyboardType(.numberPad)
                }
                Section(header: Text("Address")) {
                    TextField("Street", text: $street)
                    TextField("City", text: $city)
                    TextField("State", text: $residentState)
                        .textCase(.uppercase)
                    TextField("Zip", text: $zip)
                        .keyboardType(.numberPad)
                    TextField("Country", text: $country)
                        .textCase(.uppercase)
                    TextField("GateCode?", text: $gateCode)
                }
                Button(action: {
                    saveClient()
                }, label: {
                    HStack {
                        Spacer(minLength: 14)
                        Text("Save")
                            .padding(.vertical, 14)
                            .lineLimit(1)
                            .font(Font.body.weight(.semibold))
                        
                        Spacer(minLength: 14)
                    }
                    .foregroundColor(.white)
                    .background(Color.brandPrimary)
                    .cornerRadius(50)
                })
                    .disabled(addButtonDisabled)
                
            }
            .navigationTitle("Add Client")
            .alert(isPresented: $showingAddAlert, content: {
                Alert(title: Text(addAlertTitle), message: Text(addAlertMessage), dismissButton: .default(Text("OK"), action: {
                    presentationMode.wrappedValue.dismiss()
                }))
            })
        }
        .accentColor(.brandPrimary)
    }
    
    func saveClient() {
        let address = Address()
        address.street = street
        address.city = city
        address.state = residentState
        address.zip = zip
        address.country = country
        address.gateCode = gateCode
        
        let newClient = Client()
        newClient.firstName = firstName
        newClient.lastName = lastName
        newClient.address = address
        newClient.email = email
        newClient.phoneNumber = phone
        newClient.partition = "public=\(state.user?.companyID ?? "")"
        
        $clients.append(newClient)
        print($clients)
        
        addAlertTitle = "Success"
        addAlertMessage = "New client added!"
        showingAddAlert = true
    }
}

//struct AddClientView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddClientView(clients: Client.example)
//    }
//}

