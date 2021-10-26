//
//  SendShiftRequestView.swift
//  SendShiftRequestView
//
//  Created by Hayden Davidson on 8/10/21.
//

import SwiftUI
import RealmSwift

struct SendShiftRequestView: View {
    @Environment(\.calendar) var calendar
    @EnvironmentObject var state: AppState
    @Environment(\.realm) var publicRealm
    @ObservedResults(Request.self) var requests
    
    var crewMember: CrewMember?
    
    var crew: [CrewMember]?
    
    var crewName: String?
    
    @State var date: Date
    
    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var shiftType: ShiftType = .fullDay
    @State private var role: Role = .member
    
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    
    
    var body: some View {
        VStack{
            Form {
                Section(header: Text("Shift Type")) {
                    Picker("Shift Type", selection: $shiftType) {
                        ForEach(Array(ShiftType.allCases), id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                    DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                }
                
                if crew == nil {
                    Section(header: Text("Shift Position")) {
                        Picker("Role", selection: $role) {
                            ForEach(Array(Role.allCases), id: \.self) {
                                Text($0.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
                
                
                Section(header: Text("Description")) {
                    Text("Request \(crew != nil ? "Crew: \(crewName ?? "")" : crewMember?.displayName ?? "") to work a \(shiftType.rawValue) shift on \(date.formatted(date: .numeric, time: .omitted)) from \(startTime.formatted(date: .omitted, time: .shortened)) to \(endTime.formatted(date: .omitted, time: .shortened)) \(crew != nil ? "" : "with the position of \(role.rawValue)")")
                        .multilineTextAlignment(.center)
                }
            }
            
            CallToActionButton(title: "Send Shift Request") {
                
                if crew != nil {
                    requestCrew()
                } else {
                    if let crewMember = crewMember {
                        sendRequest(to: crewMember)
                    }
                }
            }
            .padding()
            
            
            
        }
        .accentColor(.brandPrimary)
        .alert(isPresented: $showingAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .onAppear {
            initData()
        }
        .onChange(of: shiftType) { newValue in
            setStartandEndTime()
        }
        .navigationBarTitle("Shift Builder")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    
    func requestCrew() {
        guard let crew = crew else { return }
        
        for crewMember in crew {
            sendRequest(to: crewMember)
        }
    }
    
    func sendRequest(to crewMember: CrewMember) {
        print("Date selected")
        print(date.formatted())
        print("Start Time")
        print(startTime.formatted())
        print("End Time")
        print(endTime.formatted())
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let stringDate = formatter.string(from: date)
        
        let startTimeString = getTime(date: startTime)
        let endTimeString = getTime(date: endTime)
        
        
        
        let newShift = Shift()
        newShift.startTime = startTime
        newShift.EndTime = endTime
        newShift.date = date
        newShift.crewMember = crewMember._id
        newShift.type = shiftType.asString
        
        let newRequest = Request()
        newRequest.crewMember = crewMember.userName
        newRequest.shift = newShift
        if crew == nil {
            newRequest.role = role.asString
        }
        newRequest.company = state.user?.companyID
        newRequest.sender = state.user?.userName
        newRequest.typeState = .shift
        newRequest.recipient = crewMember.userName
        newRequest.requestState = .pending
        
        newRequest.requestDescription = "\(newRequest.sender ?? "") has requested \(newRequest.recipient ?? "") to work a \(newShift.type) shift on \(stringDate) from \(startTimeString) to \(endTimeString)"
        
        print(newRequest)
        try! publicRealm.write {
            $requests.append(newRequest)
        }
        
        alertTitle = "Success"
        alertMessage = "Sent shift request to \(crew != nil ? crewName ?? "" : newRequest.recipient ?? "Crew Member")"
        showingAlert = true
    }
    
    func getTime(date: Date) -> String {
        return date.formatted(date: .omitted, time: .shortened)
        
    }
    
    func initData() {
        
        setStartandEndTime()
        guard let crewMember = crewMember else { return }
        
        switch crewMember.role {
        case "Member":
            self.role = .member
            
        case "Manager":
            self.role = .manager
            
        case "Admin":
            self.role = .admin
            
        default:
            self.role = .member
        }
        
    }
    
    func setStartandEndTime() {
        var components =  Calendar.current.dateComponents([.year,.month, .day, .hour, .minute], from: date)
        
        switch shiftType {
        case .morning:
            components.hour = 8
            components.minute = 0
            startTime = calendar.date(from: components) ?? Date()
            
            components.hour = 12
            endTime = Calendar.current.date(from: components) ?? Date()
            
        case .afternoon:
            components.hour = 13
            components.minute = 0
            startTime = Calendar.current.date(from: components) ?? Date()
            
            components.hour = 17
            endTime = Calendar.current.date(from: components) ?? Date()
            
        case .fullDay:
            components.hour = 8
            components.minute = 0
            startTime = Calendar.current.date(from: components) ?? Date()
            
            components.hour = 17
            endTime = Calendar.current.date(from: components) ?? Date()
        }
    }
}

//struct SendShiftRequestView_Previews: PreviewProvider {
//    static var previews: some View {
//        SendShiftRequestView()
//    }
//}
