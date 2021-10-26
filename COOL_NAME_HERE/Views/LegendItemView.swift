//
//  LegendItemView.swift
//  LegendItemView
//
//  Created by Hayden Davidson on 8/4/21.
//

import SwiftUI

struct LegendItemView: View {
    var body: some View {
        VStack {
            ZStack {
                
                Circle()
                    .foregroundColor(.halfDayPM)
                    .frame(width: 30)
                Text("\(5)")
            }
            Text("Half (PM)")
                .font(.caption)
        }
        .frame(width: 30, height: 50)
    }
}

struct LegendItemView_Previews: PreviewProvider {
    static var previews: some View {
        LegendItemView()
    }
}
