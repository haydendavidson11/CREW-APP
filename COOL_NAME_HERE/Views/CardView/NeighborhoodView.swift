//
//  NeighborhoodView.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 5/7/21.
//

import SwiftUI
import RealmSwift
import CoreLocation

struct NeighborhoodView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.realm) var publicRealm
    
    @ObservedRealmObject var project: Project
    
    @State private var neighborhood = ""
    @State private var city = ""
    
    var body: some View {
        
        VStack {
            if neighborhood != "" {
                HStack {
                    Image(systemName: "house.circle")
                    Text(neighborhood)
                }
            }
            if city != "" {
                HStack {
                    Image(systemName: "building.2.crop.circle")
                    Text(city)
                }
            }
        }.onAppear(perform: getClientNeighborhood)
    }
    
    func getClientNeighborhood() {
        let project = project
        guard let projectAddress = project.address else { return }
        let addressString = "\(projectAddress.street ?? "") \(projectAddress.city ?? "") \(projectAddress.state ?? "") \(projectAddress.zip ?? "") \(projectAddress.country ?? "")"
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString) { (placemarks, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            
            guard let placemark = placemarks?.first else {
                return
            }

            neighborhood = placemark.subLocality ?? ""
            city = placemark.locality ?? ""
        }
    }
}

//struct NeighborhoodView_Previews: PreviewProvider {
//    static var previews: some View {
//        NeighborhoodView()
//    }
//}
