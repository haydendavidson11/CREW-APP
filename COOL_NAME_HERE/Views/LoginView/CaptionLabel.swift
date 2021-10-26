//
//  CaptionLabel.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 4/12/21.
//

import SwiftUI

struct CaptionLabel: View {
    let title: String
    
    private let lineLimit = 5

    var body: some View {
        HStack {
            Text(LocalizedStringKey(title))
                .font(.caption)
                .lineLimit(lineLimit)
                .multilineTextAlignment(.leading)
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}

//struct CaptionLabel_Previews: PreviewProvider {
//    static var previews: some View {
//            CaptionLabel(title: "Title")
//    }
//}

