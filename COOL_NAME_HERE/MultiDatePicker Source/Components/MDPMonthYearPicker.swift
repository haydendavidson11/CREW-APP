//
//  MonthYearPicker.swift
//  MultiDatePickerApp
//
//  Created by Peter Ent on 11/2/20.
//

import SwiftUI


struct MDPMonthYearPicker: View {
    let months = (0...11).map {$0}
    let years = (1970...2099).map {$0}
    
    var date: Date
    var action: (Int, Int) -> Void
    
    @State private var selectedMonth = 0
    @State private var selectedYear = 2020
    
    init(date: Date, action: @escaping (Int, Int) -> Void) {
        self.date = date
        self.action = action
        
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        
        self._selectedMonth = State(initialValue: month - 1)
        self._selectedYear = State(initialValue: year)
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Picker("", selection: self.$selectedMonth) {
                ForEach(months, id: \.self) { month in
                    Text("\(Calendar.current.monthSymbols[month])").tag(month)
                        .foregroundColor(.primary)
                }
            }.pickerStyle(.wheel)
            .onChange(of: selectedMonth, perform: { value in
                self.action(value + 1, self.selectedYear)
            })
            .frame(width: 200)
            .clipped()
            
            Picker("", selection: self.$selectedYear) {
                ForEach(years, id: \.self) { year in
                    Text(String(format: "%d", year)).tag(year)
                        .foregroundColor(.primary)
                }
            }.pickerStyle(.wheel)
            .onChange(of: selectedYear, perform: { value in
                self.action(self.selectedMonth + 1, value)
            })
            .frame(width: 100)
            .clipped()
        }
    }
}

struct MonthYearPicker_Previews: PreviewProvider {
    static var previews: some View {
        MDPMonthYearPicker(date: Date()) { (month, year) in
            print("You picked \(month), \(year)")
        }
        .frame(width: 300, height: 300)
    }
}
