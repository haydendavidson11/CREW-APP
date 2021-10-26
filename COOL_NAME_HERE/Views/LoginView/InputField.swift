//
//  InputField.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 4/12/21.
//

import SwiftUI

struct InputField: View {
    @State var title: String
    @Binding private(set) var text: String
    @EnvironmentObject var state: AppState

    var showingSecureField = false

    private enum Dimensions {
        static let noSpacing: CGFloat = 0
        static let bottomPadding: CGFloat = 16
        static let iconSize: CGFloat = 20
    }

    var body: some View {
        VStack(spacing: Dimensions.noSpacing) {
            CaptionLabel(title: title)
                .padding(.bottom, 4)
            HStack(spacing: Dimensions.noSpacing) {
                if !showingSecureField {
                    TextField("", text: $text)
                        .textContentType(.emailAddress)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom, Dimensions.bottomPadding)
                        .foregroundColor(.primary)
                        .font(.body)
                } else {
                    SecureField("", text: $text)
                        .textContentType(.password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom, Dimensions.bottomPadding)
                        .foregroundColor(.primary)
                        .font(.body)
                }
            }
        }
    }
}

//struct InputField_Previews: PreviewProvider {
//    static var previews: some View {
//                InputField(title: "Input", text: .constant("Data"))
//    }
//}

