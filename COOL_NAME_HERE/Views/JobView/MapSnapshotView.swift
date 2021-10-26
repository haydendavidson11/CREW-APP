//
//  MapSnapshotView.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 6/21/21.
//

import SwiftUI
import MapKit

struct MapSnapshotView: View {
    let location: CLLocationCoordinate2D
    var span: CLLocationDegrees = 0.003
    
    var locationName: String
    
    @State private var snapshotImage: UIImage? = nil
    
    var body: some View {
        GeometryReader { geometry in
            Group {
                if let image = snapshotImage {
                    ZStack {
                        Image(uiImage: image)
                        VStack(spacing: 1) {
                            Image(systemName: "mappin")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.red)
                                .frame(width: 10)
                            
                            Text(locationName)
                                .font(.caption)
                                .lineLimit(1)
                                .minimumScaleFactor(0.50)
                                .padding(3)
                                .background(.ultraThinMaterial)
                                .cornerRadius(5)
                        }
                    }
                } else {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            ProgressView().progressViewStyle(CircularProgressViewStyle())
                            Spacer()
                        }
                        Spacer()
                    }
                    .background(Color(UIColor.secondarySystemBackground))
                }
                
            }
            
            .onAppear {
                generateSnapshot(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
    
    func generateSnapshot(width: CGFloat, height: CGFloat) {
        
        // The region the map should display.
        let region = MKCoordinateRegion(
            center: self.location,
            span: MKCoordinateSpan(
                latitudeDelta: self.span,
                longitudeDelta: self.span
            )
        )
        
        // Map options.
        let mapOptions = MKMapSnapshotter.Options()
        mapOptions.region = region
        mapOptions.size = CGSize(width: width, height: height)
        mapOptions.showsBuildings = false
        
        // Create the snapshotter and run it.
        let snapshotter = MKMapSnapshotter(options: mapOptions)
        snapshotter.start { (snapshotOrNil, errorOrNil) in
            if let error = errorOrNil {
                print(error)
                return
            }
            if let snapshot = snapshotOrNil {
                self.snapshotImage = snapshot.image
            }
        }
    }
}

struct MapSnapshotView_Previews: PreviewProvider {
    static var previews: some View {
        let coordinates = CLLocationCoordinate2D(latitude: 37.332077, longitude: -122.02962) // Apple Park, California
        MapSnapshotView(location: coordinates, locationName: "Hayden Davidson")
    }
}
