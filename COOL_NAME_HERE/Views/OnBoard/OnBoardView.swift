//
//  OnBoardView.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 6/11/21.
//

import SwiftUI

struct OnBoardView: View {
    
    @State private var isActive = false
    
    var body: some View {
        NavigationView {
            VStack {
                TabView {
                    PageView(imageName: "person.3.fill", imageSize: 120, info: StringContent.appDescription)
                    PageView(imageName: "calendar.badge.plus", imageSize: 120, info: StringContent.thirdPageContent)
                    PageView(imageName: "barcode.viewfinder", imageSize: 120, info: StringContent.secondPageContent)
                    PageView(imageName: "paperplane", imageSize: 120, info: StringContent.fourthPageContent)
                }
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                
                NavigationLink(destination: CreateOrJoinView(), isActive: $isActive, label: {
                    CallToActionButton(title: "Get Started", action: {self.isActive = true})
                })
                    .padding(.horizontal)
                
            }
            .navigationBarHidden(true)
        }
    }
}

struct OnBoardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OnBoardView()
                .environment(\.colorScheme, .dark)
            OnBoardView()
                .environment(\.colorScheme, .light)
        }
    }
}
