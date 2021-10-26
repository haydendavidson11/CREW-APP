//
//  ThumbnailWithExpand.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 5/13/21.
//

import SwiftUI

struct ThumbnailWithExpand: View {
    let photo: Photo
    
    @State private var showingFullImage = false
    
    private enum Dimensions {
        static let frameSize: CGFloat = 100
        static let imageSize: CGFloat = 70
        static let buttonSize: CGFloat = 30
        static let radius: CGFloat = 8
        static let buttonPadding: CGFloat = 4
    }
    
    var body: some View {
        VStack {
            Button(action: { showingFullImage = true }) {
                ThumbNailView(photo: photo)
                    .frame(width: Dimensions.imageSize, height: Dimensions.imageSize, alignment: .center)
                    .clipShape(RoundedRectangle(cornerRadius: Dimensions.radius))
            }.sheet(isPresented: $showingFullImage) {
                PhotoFullSizeView(photo: photo)
            }
        }
    }
}

//struct ThumbnailWithExpand_Previews: PreviewProvider {
//    static var previews: some View {
//        ThumbnailWithExpand()
//    }
//}
