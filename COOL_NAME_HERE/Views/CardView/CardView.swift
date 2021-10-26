//
//  Card.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 3/28/21.
//

import SwiftUI
import RealmSwift

struct CardView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.realm) var publicRealm
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedRealmObject var client: Client
    @ObservedObject private var keyboard = KeyboardResponder()
    
    @State private var offset = CGSize.zero
    @State private var feedback = UINotificationFeedbackGenerator()
    @State private var showMaterials = false
    @State private var category = ""
        
    var labelColor: Color {
        switch client.categoryState {
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
        NavigationView {
            ZStack {
                Rectangle()
                    .fill(LinearGradient(gradient: Gradient(colors: [.brandSecondary, Color(UIColor.secondarySystemBackground)]), startPoint: .top, endPoint: .bottom))
                    .background(Rectangle())
                    .shadow(radius: 5)
                ScrollView {
                    VStack(alignment: .leading){
                        HStack{
                            
                            Spacer()
                        }
                        .padding()
                        ContactView(client: client)
                            .environment(\.realmConfiguration,
                                          app.currentUser!.configuration(partitionValue: "public=\(state.user?.companyID ?? "")"))
                        Divider()
                            .padding([.leading, .trailing])
                        JobsView(client: client)
                            .environment(\.realmConfiguration,
                                          app.currentUser!.configuration(partitionValue: "public=\(state.user?.companyID ?? "")"))
                        CommentView(client: client)
                            .environment(\.realmConfiguration,
                                          app.currentUser!.configuration(partitionValue: "public=\(state.user?.companyID ?? "")"))
                    }
                }
                .padding(.bottom)
                .padding(.bottom, keyboard.currentHeight)
                .animation(.easeInOut(duration: 0.16), value: keyboard.currentHeight)
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarHidden(true)
            .onAppear(perform: {
                self.category = client.category
            })
            .offset(x: offset.width , y: 0)
        }
    }
}

//struct CardView_Previews: PreviewProvider {
//    static var previews: some View {
//        CardView(client: Client())
//    }
//}
//MARK: - Contact View

struct ContactView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.realm) var publicRealm
    
    @ObservedRealmObject var client: Client
    
    @State private var edit = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack{
                if edit {
                    VStack{
                        HStack{
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
                    HStack {
                        Text("\(client.firstName.capitalized) \(client.lastName.capitalized)")
                            .font(.largeTitle)
                            .padding()
                        Spacer()
                        
                        if state.canEditAndDelete {
                            Button(action: {self.edit.toggle()}) {
                                Image(systemName: "pencil")
                                    .padding()
                            }.buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            
            Divider()
            
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
        }
        .padding()
        .multilineTextAlignment(.center)
    }
}

//MARK: - CommentView

struct CommentView: View {
    
    @EnvironmentObject var state: AppState
    @Environment(\.realm) var publicRealm
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedRealmObject var client: Client
    
    @State private var commentMessage = ""
    @State private var showActivity = false
    @State private var showingImagePicker = false
    @State private var source: UIImagePickerController.SourceType = .photoLibrary
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
                Toggle("Show Activity", isOn: $showActivity)
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
                    showingImagePicker.toggle()
                    source = .photoLibrary
                }) {
                    Image(systemName: "paperclip")
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    showingImagePicker.toggle()
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
            .fullScreenCover(isPresented: $showingImagePicker, content: {
                ImagePicker(photo: $photo, photoSource: source)
                    .edgesIgnoringSafeArea(.all)
            })
            .padding([.leading, .trailing])
            
            if showActivity {
                ForEach(client.activity, id: \.id) { event in
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
        .accentColor(.brandPrimary)
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
            
            client.thaw()?.activity.insert(newEvent, at: 0)
        }
        commentMessage = ""
        photo = nil
    }
}
