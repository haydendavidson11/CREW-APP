//
//  ProjectCardView.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 6/24/21.
//

//
//  Card.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 3/28/21.
//

import SwiftUI
import RealmSwift

struct ProjectCardView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.realm) var publicRealm
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedResults(Client.self) var clients
    @ObservedResults(CrewMember.self) var crewMembers
    @ObservedRealmObject var project: Project
    @ObservedObject private var keyboard = KeyboardResponder()
    
    @State private var offset = CGSize.zero
    @State private var feedback = UINotificationFeedbackGenerator()
    @State private var showMaterials = false
    @State private var category = ""
    
    @State private var showingDatePicker = false
    
    @State private var startTime = Date()
    @State private var completionDate = Date()
    @State private var datePicker = 1
    
    var labelColor: Color {
        switch project.categoryState {
        case .archived:
            return Color.archived
        case .needsEstimate:
            return Color.needsEstimate
        case .estimatePending:
            return Color.estimatePending
        case .toBeScheduled:
            return Color.toBeScheduled
        case .scheduled:
            return Color.scheduled
        case .complete:
            return Color.complete
        }
    }
    
    
    var body: some View {
        let client =  clients.first(where: { client in
            "\(client.firstName) \(client.lastName)" == project.client
        }) ?? Client()
        
        NavigationView {
            ZStack {
                Rectangle()
                    .fill(LinearGradient(gradient: Gradient(colors: [labelColor, Color(UIColor.secondarySystemBackground)]), startPoint: .top, endPoint: .bottom))
                    .background(Rectangle())
                    .shadow(radius: 5)
                ScrollView {
                    VStack(alignment: .leading){
                        HStack{
                            VStack(alignment: .leading) {
                                Text(project.name ?? "")
                                    .font(.title)
                                    .minimumScaleFactor(0.75)
                                    .lineLimit(2)
                                HStack {
                                    Text("Start Date:")
                                        .font(.caption)
                                        .minimumScaleFactor(0.75)
                                        .lineLimit(1)
                                    
                                    Text("\(project.startTime?.formatted(date: .numeric ,time: .shortened) ?? "")")
                                        .underline()
                                        .font(.caption)
                                        .minimumScaleFactor(0.75)
                                        .lineLimit(1)
                                        .onTapGesture(perform: {
                                            if state.canEditAndDelete {
                                                datePicker = 1
                                                showingDatePicker = true
                                            }
                                        })
                                        .popover(isPresented: $showingDatePicker) {
                                            if datePicker == 1 {
                                                VStack(alignment: .leading) {
                                                    Text("Start Date")
                                                        .font(.title)
                                                        .padding()
                                                DatePicker("Start Date", selection: $startTime, displayedComponents: [.date, .hourAndMinute])
                                                    .datePickerStyle(.graphical)
                                                    .labelsHidden()
                                                    .onDisappear {
                                                        //Save Start Date for projects
                                                        print("Save")
                                                        try! publicRealm.write {
                                                            project.thaw()?.startTime = startTime
                                                            project.thaw()?.startDate = startTime
                                                        }
                                                    }
                                                }
                                            } else {
                                                VStack(alignment: .leading) {
                                                    Text("Completion Date")
                                                        .font(.title)
                                                        .padding()
                                                DatePicker("Completion Date", selection: $completionDate, displayedComponents: [.date, .hourAndMinute])
                                                    .datePickerStyle(.graphical)
                                                    .labelsHidden()
                                                    .onDisappear {
                                                        //Save Start Date for projects
                                                        print("Save")
                                                        let date = Date()
                                                        try! publicRealm.write {
                                                            project.thaw()?.completionDate = completionDate
                                                            project.thaw()?.completionDate = completionDate
                                                            
                                                            guard let dateCompleted = project.completionDate else {return}
                                                            if dateCompleted  <= date {
                                                                project.thaw()?.categoryState = .complete
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                }
                                if project.completionDate != nil {
                                    HStack {
                                        Text("Completion Date:")
                                            .font(.caption)
                                            .minimumScaleFactor(0.75)
                                            .lineLimit(1)
                                        
                                        Text("\(project.completionDate?.formatted(date: .numeric ,time: .omitted) ?? "")")
                                            .underline()
                                            .font(.caption)
                                            .minimumScaleFactor(0.75)
                                            .lineLimit(1)
                                            .onTapGesture(perform: {
                                                if state.canEditAndDelete {
                                                    datePicker = 2
                                                    showingDatePicker = true
                                                }
                                            })
                                    }
                                }
                            }
                            
                                
                            Spacer()
                            Text(project.category)
                                .animation(.easeInOut)
                                .padding()
                                .background(Color.white
                                                .opacity(0.3))
                                .clipShape(Capsule())
                                .shadow(radius: 10)
                                .contextMenu(state.canEditAndDelete ? ContextMenu(menuItems: {
                                    ContextButton(project: project, label: "Archived", category: .archived)
                                    ContextButton(project: project, label: "Needs Estimate", category: .needsEstimate)
                                    ContextButton(project: project, label: "Estimate Pending", category: .estimatePending)
                                    ContextButton(project: project, label: "To Be Scheduled", category: .toBeScheduled)
                                    ContextButton(project: project, label: "Scheduled", category: .scheduled)
                                    ContextButton(project: project, label: "Complete", category: .complete)
                                    
                                }) : nil)
                            
                        }
                        .padding()
                        
                        ProjectContactView(client: client)
                            .environment(\.realmConfiguration,
                                          app.currentUser!.configuration(partitionValue: "public=\(state.user?.companyID ?? "")"))
                        Divider()
                            .padding([.leading, .trailing])
                        ProjectCrewView(project: project)
                            .environment(\.realmConfiguration,
                                          app.currentUser!.configuration(partitionValue: "public=\(state.user?.companyID ?? "")"))
                        
                        TodoListView(project: project)
                            .environment(\.realmConfiguration,
                                          app.currentUser!.configuration(partitionValue: "public=\(state.user?.companyID ?? "")"))
                        
                        MaterialsView(project: project)
                            .environment(\.realmConfiguration,
                                          app.currentUser!.configuration(partitionValue: "public=\(state.user?.companyID ?? "")"))
                        
                        ProjectCommentView(project: project)
                            .environment(\.realmConfiguration,
                                          app.currentUser!.configuration(partitionValue: "public=\(state.user?.companyID ?? "")"))
                    }
                    .padding(.bottom)
                    
                }
                .padding(.bottom)
                .padding(.bottom, keyboard.currentHeight)
                .animation(.easeInOut(duration: 0.16), value: keyboard.currentHeight)
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarHidden(true)
            .onAppear(perform: {
                withAnimation {
                    self.category = project.category
                }
            })
            .onChange(of: project.category, perform: { newValue in
                self.category = project.category
            })
            .offset(x: offset.width , y: 0)
            .accentColor(.brandPrimary)
            
        }
    }
}



//struct ProjectCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProjectCardView(client: Client())
//    }
//}

//MARK: - projectCrew View

struct ProjectCrewView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.realm) var publicRealm
    @Environment(\.presentationMode) var presentationMode

    @ObservedRealmObject var project: Project
    
    @State private var showingAddPeopleView = false
    
    let columns = [GridItem(.flexible()),
                   GridItem(.flexible()),
                   GridItem(.flexible())]
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack() {
                Text("Crew")
                    .font(.title2)
                Spacer()
                
                if state.canEditAndDelete {
                    Button(action: {showingAddPeopleView = true}) {
                        Image(systemName: "plus")
//                            .foregroundColor(.brandPrimary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
            
            if project.crew.count > 0 {
                LazyVGrid(columns: columns) {
                    CrewMemberGridItemView(project: project)
                        .environment(\.realmConfiguration,
                                      app.currentUser!.configuration(partitionValue: "public=public"))
                }
            }
            Divider()
                .padding(.horizontal)
        }
        
        .accentColor(.brandPrimary)
        .sheet(isPresented: $showingAddPeopleView) {
            AddCrewMemberView(project: project)
                .environment(\.realmConfiguration,
                              app.currentUser!.configuration(partitionValue: "public=public"))
        }
    }
}


//MARK: - CommentView

struct ProjectCommentView: View {
    
    @EnvironmentObject var state: AppState
    @Environment(\.realm) var publicRealm
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedRealmObject var project: Project
    @ObservedResults(CrewMember.self) var crewMembers
    
    @State private var showingImagePicker = false
    @State private var source: UIImagePickerController.SourceType = .photoLibrary
    @State private var commentMessage = ""
    @State private var showActivity = false
    @State private var photo: Photo? {
        didSet {
            print("photo captured")
        }
    }
    
    var emptyComment: Bool {
        if commentMessage != "" || photo != nil {
            return false
        } else {
            return true
        }
    }
    
    var body: some View {
        
        VStack {
            
            HStack {
                Image(systemName: "text.bubble")
                Text("Show Activity")
                Spacer()
                Toggle("Show Activity", isOn: withAnimation{ $showActivity })
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: Color.brandPrimary))
            }
            .padding([.leading, .trailing])
            HStack {
                TextField("Add Comment...", text: $commentMessage)
                    
                if photo != nil {
                    ThumbnailWithDelete(photo: photo, action: deletePhoto)
                }
                Button(action: {
                    showingImagePicker = true
                    source = .photoLibrary
                }) {
                    Image(systemName: "paperclip")
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    showingImagePicker = true
                    source = .camera
                }) {
                    Image(systemName: "camera")
                }
                .buttonStyle(PlainButtonStyle())
                Spacer()
                Button("Add") {
                    addComment()
                }
                .disabled(emptyComment)
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.bottom)
            .fullScreenCover(isPresented: $showingImagePicker, content: {
                ImagePicker(photo: $photo, photoSource: source)
                    .edgesIgnoringSafeArea(.all)
            })
            .padding([.leading, .trailing])
            
            
            
            if showActivity {
                ForEach(project.activity, id: \.id) { event in
                    HStack() {
                        AvatarThumbNailView(photo: event.userAvatar ?? Photo(), imageSize: 50)
                        VStack(alignment: .leading) {
                            if event.image != nil {
                                ThumbnailWithExpand(photo: event.image!)
                            }
                            Text(event.info ?? "")
                            HStack {
                                Text(event.typeState.asString)
                                    .font(.caption)
                                Text(event.date ?? "")
                                    .font(.caption)
                            }
                        }
                        .padding()
                        Spacer()
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 10.0, style: .continuous))
                .padding()
            }
        }
    }
    
    func deletePhoto() {
        self.photo = nil
    }
    
    
    func addComment() {
        
        let newEvent = Event()
        
        let publicConfig =  app.currentUser!.configuration(partitionValue: "public=public")
        let realm = try! Realm(configuration: publicConfig)
        
        let crewMembers = realm.objects(CrewMember.self)
        
        if let crewMember = crewMembers.first(where: {$0._id == state.user?._id}) {
            newEvent.userAvatar = Photo()
            newEvent.userAvatar?.thumbNail = crewMember.avatarImage?.thumbNail
            newEvent.userAvatar?.picture = crewMember.avatarImage?.picture
            newEvent.userAvatar?._id = crewMember.avatarImage?._id ?? ""
            newEvent.userAvatar?.date = crewMember.avatarImage?.date ?? Date()
        }
        
        try! publicRealm.write {
            let formatter = DateFormatter()
            
            formatter.timeStyle = .short
            formatter.dateStyle = .short
            
            let dateString = formatter.string(from: Date())
            
            newEvent.typeState = .comment
            newEvent.info = commentMessage
            newEvent.date = dateString
            if self.photo != nil {
                newEvent.image = photo
                print("event photo set")
            }
            
            project.thaw()?.activity.insert(newEvent, at: 0)
        }
        commentMessage = ""
        photo = nil
    }
}


struct ProjectContactView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.realm) var publicRealm
    
    @ObservedRealmObject var client: Client
    
    @State private var edit = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Divider()
            HStack{
                if edit {
                    VStack{
                        HStack{
                            Text("Client")
                                .font(.title2)
                            Spacer()
                            
                            if state.canEditAndDelete {
                                Button(action: {
                                    self.edit.toggle()
                                }) {
                                    Text("Done")
                                        .padding()
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                        }
                        HStack{
                            Text("First:")
                                .font(.caption)
                            TextField("\(client.firstName.capitalized)", text: $client.firstName)
                                .multilineTextAlignment(.leading)
                            
                            Text("Last:")
                                .font(.caption)
                            TextField("\(client.firstName.capitalized)", text: $client.lastName)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                    }
                    
                } else {
                    
                    VStack {
                        HStack {
                            Text("Client")
                                .font(.title2)
                            Spacer()
                            
                            if state.canEditAndDelete {
                                Button(action: {self.edit.toggle()}) {
                                    Image(systemName: "pencil")
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                            }
                        }
                        .padding(.vertical)
                        HStack {
                            Image(systemName: "person")
                            Text("\(client.firstName.capitalized) \(client.lastName.capitalized)")
                            Spacer()
                        }
                    }
                }
            }
            
            HStack {
                Image(systemName: "envelope")
                if edit {
                    TextField(client.email, text: $client.email)
                        .multilineTextAlignment(.leading)
                } else {
                    Text(client.email)
                }
            }
            .padding(.top)
            HStack {
                Image(systemName: "phone")
                if edit {
                    TextField(client.phoneNumber, text: $client.phoneNumber)
                        .multilineTextAlignment(.leading)
                } else {
                    Text(client.phoneNumber)
                }
            }
            .padding(.top)
            AddressView(client: client, address: client.address ?? Address(), edit: $edit)
                .padding(.top)
                .environment(\.realmConfiguration,
                              app.currentUser!.configuration(partitionValue: "public=\(state.user?.companyID ?? "")"))
        }
        .padding(.horizontal)
        .multilineTextAlignment(.center)
    }
}



struct CrewMemberGridItemView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.realm) var publicRealm
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedResults(CrewMember.self) var crewMembers
    @ObservedRealmObject var project: Project
    
  
    var body: some View {
        ForEach(project.crew, id: \.self) { member in
            if let crewMember = crewMembers.first(where: { person in
                person._id == member
            }) {
                VStack {
                    AvatarThumbNailView(photo: crewMember.avatarImage ?? Photo(), imageSize: 80)
                    Text(crewMember.displayName ?? "")
                        .font(.caption)
                        .foregroundColor(.brandPrimary)
                }
                .contextMenu() {
                    if state.canEditAndDelete {
                        Button(role: .destructive) {
                            
                            removeCrewMember(member)
                            
                        } label: {
                            Label("Remove", systemImage: "trash")
                        }
                    }
                }
            }
        }
    }
    
    func removeCrewMember(_ member: String) {
        let formatter = DateFormatter()
        
        let companyConfig =  app.currentUser!.configuration(partitionValue: "public=\(state.user?.companyID ?? "")")
        
        try! Realm(configuration: companyConfig).write {
            if let index =  project.crew.index(of: member) {
                project.thaw()?.crew.remove(at: index)
                
                let newEvent = Event()
                if let crewMember = crewMembers.first(where: {$0._id == state.user?._id}) {
                    newEvent.userAvatar = Photo()
                    newEvent.userAvatar?.thumbNail = crewMember.avatarImage?.thumbNail
                    newEvent.userAvatar?.picture = crewMember.avatarImage?.picture
                    newEvent.userAvatar?._id = crewMember.avatarImage?._id ?? ""
                    newEvent.userAvatar?.date = crewMember.avatarImage?.date ?? Date()
                    
                    formatter.timeStyle = .short
                    formatter.dateStyle = .short
                    
                    let dateString = formatter.string(from: Date())
                    
                    newEvent.date = dateString
                    newEvent.typeState = .crewMemberRemoved
                    
                    if let personToRemove = crewMembers.first(where: {$0._id == member}) {
                        newEvent.info = "\(personToRemove.displayName ?? "") removed from crew"
                    }
                    project.thaw()?.activity.insert(newEvent, at: 0)
                }
            }
        }
    }
}
