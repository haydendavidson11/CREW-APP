//
//  NavigationButton.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 6/14/21.
//

import SwiftUI

struct NavigationButton: View {
    var title: String
    var action: () -> Void
    var destination: AnyView
    
    @State var isActive = false
    

    
    var body: some View {
        NavigationLink(destination: destination, isActive: $isActive, label: {
            ZStack {
                RoundedRectangle(cornerRadius: 50)
                    .frame(height: 50)
                    .foregroundColor(.brandPrimary)
                Text(title)
                    .foregroundColor(.white)
                    .bold()
            }
            .onTapGesture {
                action()
                print("NavButtonAction")
                isActive = true
                    
            }
        })
            .padding(.horizontal)
    }
}

struct NavigationButton_Previews: PreviewProvider {
    static var previews: some View {
        NavigationButton(title: "Save", action: {}, destination: AnyView(MainView()))
    }
}
