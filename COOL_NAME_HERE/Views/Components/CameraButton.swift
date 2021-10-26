//
//  CameraButton.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 5/11/21.
//

import SwiftUI

struct CameraButton: View {
    let action: () -> Void
    var active = true
    
    var body: some View {
        ButtonTemplate(action: action, active: active, activeImage: "camera.fill", inactiveImage: "camera")
    }
}

//struct CameraButton_Previews: PreviewProvider {
//    static var previews: some View {
//        CameraButton()
//    }
//}
