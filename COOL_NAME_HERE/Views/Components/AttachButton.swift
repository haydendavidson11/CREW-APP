//
//  AttachButton.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 5/11/21.
//

import SwiftUI

struct AttachButton: View {
    let action: () -> Void
    var active = true
    
    var body: some View {
        ButtonTemplate(action: action, active: active, activeImage: "paperclip", inactiveImage: "paperclip")
    }
}

//struct AttachButton_Previews: PreviewProvider {
//    static var previews: some View {
//        AttachButton()
//    }
//}
