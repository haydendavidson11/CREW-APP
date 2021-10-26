//
//  CheckBox.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 4/12/21.
//

import SwiftUI


struct CheckBox: View {
    var title: String
    @Binding var isChecked: Bool

    var body: some View {
        Button(action: { self.isChecked.toggle() }) {
            HStack {
                Image(systemName: isChecked ? "checkmark.square": "square")
                Text(title)
            }
            .foregroundColor(isChecked ? .primary : .secondary)
        }
    }
}
