//
//  ImagePicker.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 5/12/21.
//

import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode) var presentationMode
    
    
    @Binding var photo: Photo? {
        didSet {
            print("we have a photo")
        }
    }
    
    var photoSource: UIImagePickerController.SourceType
    
    var photoTaken: ((ImagePicker, Photo) -> Void)?
    
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        
        var source: UIImagePickerController.SourceType {
            UIImagePickerController.isSourceTypeAvailable(.camera) ? self.photoSource : .photoLibrary
            
        }
        print(picker.mediaTypes)
        
        picker.sourceType = source
        if source == .camera {
            picker.showsCameraControls = true
            
        }
        picker.allowsEditing = true
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        let imageSizeThumbnails: CGFloat = 102
        let maximumImageSize = 1024 * 1024
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            
            guard let editedImage = info[.editedImage] as? UIImage,
                  let result = compressImageIfNeeded(image: editedImage) else {
                      print("Could't get the camera/library image")
                      return
                  }
            let newPhoto = Photo()
            newPhoto.date = Date()
            newPhoto.picture = result.jpegData(compressionQuality: 0.8)
            newPhoto.thumbNail = result.thumbnail(size: imageSizeThumbnails)?.jpegData(compressionQuality: 0.8)
            parent.photo = newPhoto
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        private func compressImageIfNeeded(image: UIImage) -> UIImage? {
            let resultImage = image
            
            if let data = resultImage.jpegData(compressionQuality: 1) {
                if data.count > maximumImageSize {
                    
                    let neededQuality = CGFloat(maximumImageSize) / CGFloat(data.count)
                    if let resized = resultImage.jpegData(compressionQuality: neededQuality),
                       let resultImage = UIImage(data: resized) {
                        print("image resized")
                        return resultImage
                        
                    } else {
                        print("Fail to resize image")
                    }
                }
            }
            return resultImage
        }
        
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
    }
    
}
