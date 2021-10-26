//
//  EditEventView.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 10/2/21.
//

import SwiftUI
import EventKit
import EventKitUI

struct EventEditView: UIViewControllerRepresentable {

    func makeCoordinator() -> Coordinator {
            return Coordinator(self)
        }

        @Environment(\.presentationMode) var presentationMode

        
        let eventStore: EKEventStore
        var event: EKEvent?
    
        

        func makeUIViewController(context: UIViewControllerRepresentableContext<EventEditView>) -> EKEventEditViewController {

            let eventEditViewController = EKEventEditViewController()
            eventEditViewController.eventStore = eventStore
            

            if let event = event {
                eventEditViewController.event = event // when set to nil the controller would not display anything
            }
            eventEditViewController.editViewDelegate = context.coordinator

            return eventEditViewController
        }

        func updateUIViewController(_ uiViewController: EKEventEditViewController, context: UIViewControllerRepresentableContext<EventEditView>) {

        }

        class Coordinator: NSObject, EKEventEditViewDelegate {
            let parent: EventEditView

            init(_ parent: EventEditView) {
                self.parent = parent
            }

            func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
            }
        }
}

//struct EditEventView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditEventView()
//    }
//}
