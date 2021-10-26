//
//  Page1.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 6/11/21.
//

import SwiftUI

struct PageView: View {
    
    let imageName: String
    let imageSize : CGFloat
    
    let info: String
    
    var body: some View {
        VStack {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: imageSize)

            Text(info)
                .multilineTextAlignment(.center)
                .padding()
                .background(.thinMaterial)
                .cornerRadius(12)
        }
        .padding()
    }
}

struct Page1_Previews: PreviewProvider {
    static var previews: some View {
        PageView(imageName: "person.3.fill", imageSize: 120, info: StringContent.appDescription)
            .environment(\.colorScheme, .dark)
    }
}
