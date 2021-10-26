//
//  CustomModifiers.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 6/12/21.
//

import SwiftUI

struct ProfileNameStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 32, weight: .bold))
            .lineLimit(1)
            .minimumScaleFactor(0.75)
    }
}
