//
//  ClientsView.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 4/7/21.
//

import SwiftUI
import RealmSwift

struct ClientsView: View {
    
    @EnvironmentObject var state: AppState
    
    @ObservedResults(Client.self) var clients
    
    @State private var showingAddClientSheet = false
    @State private var showingDetailSheet = false
    
    var body: some View {
        NavigationView{
            ClientList(clients: $clients, showingDetailSheet: $showingDetailSheet, showingAddClientSheet: $showingAddClientSheet)
                .sheet(isPresented: $showingAddClientSheet, content: {AddClientView(clients: $clients)})
        }
    }
}

//struct ClientsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ClientsView()
//    }
//}
