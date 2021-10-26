//
//  AddressView.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 3/28/21.
//

import SwiftUI
import RealmSwift

struct AddressView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.realm) var publicRealm
    
    @ObservedResults(CrewMember.self) var crewMembers
    @ObservedRealmObject var client: Client
    @ObservedRealmObject var address: Address
    
    @Binding var edit: Bool
    
    @State private var street = ""
    @State private var city = ""
    @State private var zip = ""
    @State private var residentState = ""
    @State private var country = ""
    @State private var gateCode = ""
    
    
    
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Image(systemName: "location.circle")
                VStack(alignment: .leading) {
                    if edit {
                        Group {
                            HStack {
                                Text("Street")
                                    .font(.caption)
                                TextField(address.street ?? "", text: $street)
                                    .multilineTextAlignment(.leading)
                            }
                            HStack {
                                Text("City")
                                    .font(.caption)
                                TextField(address.city ?? "", text: $city)
                                    .multilineTextAlignment(.leading)
                            }
                            HStack {
                                Text("State")
                                    .font(.caption)
                                TextField(address.state ?? "", text: $residentState)
                                    .multilineTextAlignment(.leading)
                            }
                            HStack {
                                Text("Zip")
                                    .font(.caption)
                                TextField(address.zip ?? "", text: $zip)
                                    .multilineTextAlignment(.leading)
                            }
                            HStack {
                                Text("Country")
                                    .font(.caption)
                                TextField(address.country ?? "", text: $country)
                                    .multilineTextAlignment(.leading)
                            }
                            HStack {
                                Text("GateCode")
                                    .font(.caption)
                                TextField(address.gateCode ?? "", text: $gateCode)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        .padding(.leading)
                    } else {
                        Text(address.street ?? "")
                        Text("\(address.city ?? ""), \(address.state ?? "") \(address.zip ?? "")")
                        Text(address.country ?? "")
                    }
                }
            }
            if edit {
                CallToActionButton(title: "Save", action: saveAddress)
            }
            if !edit {
                if address.gateCode != "" && address.gateCode != nil {
                    HStack(alignment: .top) {
                        Image(systemName: "lock")
                        Text(address.gateCode ?? "No Gate Code")
                    }
                    .padding(.top)
                }
            }
        }.onAppear(perform: initData)
    }
    
    //    Get the client's current address from the realm.
    func initData() {
        street = address.street ?? ""
        city = address.city ?? ""
        residentState = address.state ?? ""
        zip = address.zip ?? ""
        country = address.country ?? ""
        gateCode = address.gateCode ?? ""
        
    }
    
    //    Update the clients address in the realm.
    func saveAddress() {
        try! publicRealm.write {
            let newAddress = Address()
            
            newAddress.street = street
            newAddress.city = city
            newAddress.state = residentState
            newAddress.country = country
            newAddress.zip = zip
            newAddress.gateCode = gateCode
            client.thaw()?.address = newAddress
            print("Updated client: \(client)")
            
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            formatter.dateStyle = .short
            let dateString = formatter.string(from: Date())
            
            let newEvent = Event()
            newEvent.typeState = .contactInfoUpdated
            newEvent.info = ""
            newEvent.date = dateString
            
            if let crewMember = crewMembers.first(where: {$0._id == state.user?._id}) {
                newEvent.userAvatar = Photo()
                newEvent.userAvatar?.thumbNail = crewMember.avatarImage?.thumbNail
                newEvent.userAvatar?.picture = crewMember.avatarImage?.picture
                newEvent.userAvatar?._id = crewMember.avatarImage?._id ?? ""
                newEvent.userAvatar?.date = crewMember.avatarImage?.date ?? Date()
                
            }
            
            
            client.thaw()?.activity.insert(newEvent, at: 0)
        }
    }
    
}

//struct AddressView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddressView(address: Address(street: "385 1st ave", city: "New York", zip: "10010", state: "NY", country: "USA", gateCode: "12345"))
//    }
//}
