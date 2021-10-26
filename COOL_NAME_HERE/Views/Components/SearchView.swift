//
//  SearchView.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 4/27/21.
//

import SwiftUI

struct SearchView: View {
    @Binding var searchFilter: String
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(.gray)
                    .padding(.leading, 7)
                    .padding(.top, 7)
                    .padding(.bottom, 7)
                TextField("search", text: $searchFilter)
                    .padding(.top, 7)
                    .padding(.bottom, 7)
            }.background(RoundedRectangle(cornerRadius: 15)
                            .fill(Color(UIColor.secondarySystemBackground)))
            Spacer()
        }.frame(maxHeight: 40).padding()
    }
}

//struct SearchView_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchView()
//    }
//}
