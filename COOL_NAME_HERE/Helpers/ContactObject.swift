//
//  ContactObj.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 7/13/21.
//
import Foundation
import ContactsUI

class ContactObject : ObservableObject {
    
    @Published var cObj = CNContact()
    @Published var showContactPicker = false
   
}

