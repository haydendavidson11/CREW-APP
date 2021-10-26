//
//  ThumbnailView.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 4/29/21.
//

import UIKit
import SwiftUI

struct Thumbnail: View {
    let imageData: Data
    
    var body: some View {
        Image(uiImage: (UIImage(data: imageData) ?? UIImage()))
        .resizable()
        .aspectRatio(contentMode: .fill)
    }
}


//struct ThumbnailView_Previews: PreviewProvider {
//    static var previews: some View {
//        Thumbnail()
//    }
//}
