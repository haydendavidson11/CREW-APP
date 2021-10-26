//
//  ProjectCard.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 6/21/21.
//

import SwiftUI
import RealmSwift
import MapKit
import CoreLocation

struct ProjectCard: View {
//    var project: Project
    @ObservedRealmObject var project: Project
    
    @State private var location: CLLocationCoordinate2D?
    @State private var showingJobCard = false
    
    var dimensions: CGFloat = 200
    
    var labelColor: Color {
        switch project.categoryState {
        case .archived:
            return Color.archived
        case .needsEstimate:
            return Color.needsEstimate
        case .estimatePending:
            return Color.estimatePending
        case .toBeScheduled:
            return Color.toBeScheduled
        case .scheduled:
            return Color.scheduled
        case .complete:
            return Color.complete
        }
    }

    
    var body: some View {
        let shortAddressString = "\(project.address?.street ?? "401 Channelside Dr")"
        

            VStack(alignment: .leading, spacing: 4) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(project.name ?? "Job Name")
                        .font(.title2)
                        .lineLimit(1)
                        .minimumScaleFactor(0.50)
                    Text(project.client)
                        .font(.caption)
                        .lineLimit(1)
                        .minimumScaleFactor(0.50)
                }

                if location != nil {
                    MapSnapshotView(location: location!, locationName: shortAddressString)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.bottom, 4)

                        
                } else {
                    ProgressView().progressViewStyle(CircularProgressViewStyle())
                }
                
                HStack {
                    Button {
                        // get directions to job
                        openProjectInMaps()
                    } label: {
                        Text("Directions")
                            .padding(5)
                            .lineLimit(1)
                            .font(.system(size: 10, weight: .semibold))
                    
                    }
                    .foregroundColor(.primary)
                    .cornerRadius(8)
                    .buttonStyle(BorderedButtonStyle())
                    
                    Button {
                        self.showingJobCard = true
                    } label: {
                        Text("Details")
                            .padding(5)
                            .lineLimit(1)
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundColor(.primary)
                    .cornerRadius(8)
                    .buttonStyle(BorderedButtonStyle())
                    
                }
            }
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [labelColor, Color(UIColor.secondarySystemBackground)]), startPoint: .top, endPoint: .bottom)
                            .cornerRadius(12))
        .frame(width: dimensions, height: dimensions - 15)
        .onAppear(perform: getLocation)
        .sheet(isPresented: $showingJobCard) {
            ProjectCardView(project: project)
        }
    }
    
    func getLocation() {
        if location == nil {
            let addressString = "\(project.address?.street ?? "401 Channelside Dr") \(project.address?.city ?? "Tampa") \(project.address?.state ?? "FL") \(project.address?.zip ?? "33602") \(project.address?.country ?? "USA")"
            
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(addressString) { (placemarks, error) in
                if let error = error {
                    print(error.localizedDescription)
                }
                
                guard let placemark = placemarks?.first else {
                    print("no placemark returned")
                    
                    return
                }
                location = placemark.location?.coordinate ?? CLLocationCoordinate2D(latitude: 27.9427423, longitude: -82.4517933)
            }
        }
    }
    
    func openProjectInMaps() {

        let place = MKPlacemark(coordinate: location ?? CLLocationCoordinate2D())
        let mapItem = MKMapItem(placemark: place)
        mapItem.name = project.name
        mapItem.openInMaps(launchOptions: nil)
    }
}

struct ProjectCard_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ProjectCard(project: Project())
    }
}






