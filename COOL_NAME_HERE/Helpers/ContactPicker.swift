//
//  ContactPicker.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 7/13/21.
//


import SwiftUI
import Contacts
import ContactsUI

struct ContactPicker: UIViewControllerRepresentable {
    @EnvironmentObject var contactObj: ContactObject
    
    typealias UIViewControllerType = ContactPickerViewController
    
    func setContact(contact: CNContact ){
        self.contactObj.cObj = contact
        self.contactObj.showContactPicker = false
    }
    
    final class Coordinator: NSObject, ContactPickerViewControllerDelegate {
        var parent : ContactPicker
        
        init(_ parent: ContactPicker){
            self.parent = parent
        }
        func embeddedContactPickerViewController(_ viewController: ContactPickerViewController, didSelect contact: CNContact) {
            parent.setContact(contact: contact)
        }
        
        func embeddedContactPickerViewControllerDidCancel(_ viewController: ContactPickerViewController) {
            parent.setContact(contact: CNContact())
        }
        
    }
    
    func makeCoordinator() -> Coordinator {
        
        return Coordinator(self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ContactPicker>) -> ContactPicker.UIViewControllerType {
        let result = ContactPicker.UIViewControllerType()
        result.delegate = context.coordinator
        return result
    }
    
    func updateUIViewController(_ uiViewController: ContactPicker.UIViewControllerType, context: UIViewControllerRepresentableContext<ContactPicker>) { }
    
}






protocol ContactPickerViewControllerDelegate: AnyObject {
    func embeddedContactPickerViewControllerDidCancel(_ viewController: ContactPickerViewController)
    func embeddedContactPickerViewController(_ viewController: ContactPickerViewController, didSelect contact: CNContact)
}

class ContactPickerViewController: UIViewController, CNContactPickerDelegate {
    weak var delegate: ContactPickerViewControllerDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.open(animated: animated)
    }
    
    private func open(animated: Bool) {
        let viewController = CNContactPickerViewController()
        viewController.delegate = self
        self.present(viewController, animated: false)
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        self.dismiss(animated: false) {
            self.delegate?.embeddedContactPickerViewControllerDidCancel(self)
        }
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        self.dismiss(animated: false) {
            self.delegate?.embeddedContactPickerViewController(self, didSelect: contact)
        }
    }
    
}


