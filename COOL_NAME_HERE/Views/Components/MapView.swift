//
//  MapView.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 5/29/21.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
      var annotation: MKPointAnnotation
    
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        view.addAnnotation(annotation)
        view.showAnnotations([annotation], animated: true)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }
        
    }

}

//struct MapView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapView()
//    }
//}
