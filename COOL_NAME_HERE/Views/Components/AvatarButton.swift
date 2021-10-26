//
//  AvatarButton.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 4/29/21.
//

import SwiftUI

struct AvatarButton: View {
    @State private var showingImagePicker = false
    @State private var updatePhoto = false
    @State private var source: UIImagePickerController.SourceType = .photoLibrary
   
    @Binding var photo: Photo? {
        didSet {
            print("Avatar Button Photo Set")
        }
    }
    
    private enum Dimensions {
        static let frameWidth: CGFloat = 40
        static let frameHeight: CGFloat = 30
        static let opacity = 0.9
    
    }
    
    let action: () -> Void
    
    var body: some View {
        ZStack {
            Button(action: {
                updatePhoto = true
            }) {
                AvatarThumbNailView(photo: photo ?? Photo())
            }
            Image(systemName: "camera.fill")
                .resizable()
                .frame(width: Dimensions.frameWidth, height: Dimensions.frameHeight)
                .foregroundColor(Color(uiColor: .secondarySystemBackground))
                .opacity(Dimensions.opacity)
        }
        
        .actionSheet(isPresented: $updatePhoto, content: {
            ActionSheet(title: Text("Add Photo"), message: nil, buttons: [
                .default(Text("Camera"), action: {
                    source = .camera
                    showingImagePicker = true
                })
                , .default(Text("Photo Library"), action: {
                    showingImagePicker = true
                }),
                .cancel()
            ])
        })
        .fullScreenCover(isPresented: $showingImagePicker, onDismiss: {showingImagePicker = false}, content: {
            ImagePicker(photo: $photo, photoSource: source)
                .edgesIgnoringSafeArea(.all)
        })
    }
}

struct AvatarButton_Previews: PreviewProvider {
    static var previews: some View {
        AvatarButton(photo: .constant(Photo()), action: {})
    }
}
