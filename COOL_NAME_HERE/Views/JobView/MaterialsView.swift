//
//  AddMaterialsView.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 7/1/21.
//

import SwiftUI
import RealmSwift

struct MaterialsView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.realm) var companyRealm
    @ObservedRealmObject var project: Project
    
    @State private var showingCompanyMaterialsList = false
    @State private var showingMaterialsList = false
    

    var company: Company {
        let publicConfig =  app.currentUser!.configuration(partitionValue: "public=public")
        
        let realm = try! Realm(configuration: publicConfig)
        return realm.objects(Company.self).filter(NSPredicate(format: "_id == %@", state.user?.companyID ?? "")).first ?? Company()
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                
                Label("Show Materials", systemImage: "barcode.viewfinder")
                Spacer()
                Toggle("Show Materials", isOn: withAnimation{ $showingMaterialsList })
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: Color.brandPrimary))
                
            }
            if showingMaterialsList {
                HStack {
                    Spacer()
                    if state.canAddClient {
                        NavigationLink(destination: CompanyMaterialsList(project: project)
                                        .accentColor(.brandPrimary)
                                        .environment(\.realmConfiguration,
                                                      app.currentUser!.configuration(partitionValue: "public=public"))
                        ) {
                            Image(systemName: "plus")
                        }.buttonStyle(PlainButtonStyle())
                        
                    }
                }
                if project.materials.count > 0 {
                    ForEach(project.materials, id: \.self) { item  in
                        NavigationLink(destination: EditMaterialView(company: company, material: item, project: project)) {
                            MaterialItemView(material: item)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        state.canAddClient ? removeMaterialFromProject(item: item) : nil
                                    } label: {
                                        Label("Remove Material", systemImage: "trash")
                                    }
                                    
                                }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .padding()
    }
    
    func removeMaterialFromProject(item: Material) {
        if let pos = project.materials.firstIndex(of: item) {
          try!  companyRealm.write {
              project.thaw()?.materials.remove(at: pos)
            }
        }
    }
    
}

//MARK: - Add Material View
struct AddMaterialView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.realm) var publicRealm
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedRealmObject var company: Company
    
    @Binding var material: Material?
    
    @State private var type = ""
    @State private var itemDescription = ""
    @State private var quantity = 0.0
    @State private var SKU = ""
    @State private var price = ""
    @State private var photo: Photo?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    
    var project: Project?

    var body: some View {
        VStack {
            Section(header: Text(material?.type ?? "New Material")) {
                AvatarButton(photo: $photo, action: {})
                
                Form {
                    TextField(SKU.isEmpty ? "SKU" : SKU, text: $SKU)
                    TextField(type.isEmpty ? "Type" : type, text: $type)
                    TextField(itemDescription.isEmpty ? "Description" : itemDescription, text: $itemDescription)
                    
                    Section(header: Text("Price")) {
                        TextField(price.isEmpty ? "0.0" : price, text: $price)
                            .keyboardType(.numbersAndPunctuation)
                    }
                    if project != nil {
                        Section(header: Text("Quantity")) {
                            Stepper("\(quantity, specifier: "%g")", value: $quantity)
                        }
                    }
                }
            }
            
            CallToActionButton(title: "Add", action: {
                
               
                alertTitle = "Add Material?"
                alertMessage = "Would you like to add \(material?.type ?? "this material")? "
                showingAlert = true
            })
            
                .padding()
        }
        .accentColor(.brandPrimary)
        .padding()
        .onAppear(perform: initData)
        .alert(isPresented: $showingAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), primaryButton:
                        .default(Text("Yes"), action: {
                addMaterialToCompany(material: material)
                addMaterialToJob(material: material)
            }),
                  secondaryButton: .default(Text("NO"), action: {
                
                self.presentationMode.wrappedValue.dismiss()
            }))
        }
    }
    
    func addMaterialToCompany(material: Material?) {
        try! publicRealm.write {
            if material  == nil  {
                let newMaterial = Material()
                newMaterial.type = type
                newMaterial.SKU = SKU
                newMaterial.itemDescription = itemDescription
                newMaterial.price.value = Double(price)
                let newPhoto = Photo()
                newPhoto.picture = photo?.picture
                newPhoto.thumbNail = photo?.thumbNail
                newPhoto.date = photo?.date ?? Date()
                newMaterial.photo = newPhoto
                company.thaw()?.materials.insert(newMaterial, at: 0)
            } else {
                if company.materials.contains(material!), let pos = company.materials.firstIndex(of: material!) {
                    company.thaw()?.materials.remove(at: pos)
                    let newMaterial = Material()
                    newMaterial.type = type
                    newMaterial.SKU = SKU
                    newMaterial.itemDescription = itemDescription
                    newMaterial.price.value = Double(price)
                    let newPhoto = Photo()
                    newPhoto.picture = photo?.picture
                    newPhoto.thumbNail = photo?.thumbNail
                    newPhoto.date = photo?.date ?? Date()
                    newMaterial.photo = newPhoto
                    company.thaw()?.materials.insert(newMaterial, at: pos)
                    
                }
            }
        }
    }
    
    func addMaterialToJob(material: Material?) {
        let companyConfig =  app.currentUser!.configuration(partitionValue: "public=\(state.user?.companyID ?? "")")
        
        if project != nil {
            try! Realm(configuration: companyConfig).write {
                if material == nil {
                    
                    let newMaterial = Material()
                    newMaterial.type = type
                    newMaterial.SKU = SKU
                    newMaterial.itemDescription = itemDescription
                    newMaterial.price.value = Double(price)
                    newMaterial.quantity.value = quantity
                    let newPhoto = Photo()
                    newPhoto.picture = photo?.picture
                    newPhoto.thumbNail = photo?.thumbNail
                    newPhoto.date = photo?.date ?? Date()
                    newMaterial.photo = newPhoto
            
                    project?.thaw()?.materials.insert(newMaterial, at: 0)
                } else {
                    if project!.materials.contains(material!), let pos = project!.materials.firstIndex(of: material!) {
                        project?.thaw()?.materials.remove(at: pos)
                        
                        let newMaterial = Material()
                        newMaterial.type = type
                        newMaterial.SKU = SKU
                        newMaterial.itemDescription = itemDescription
                        newMaterial.price.value = Double(price)
                        newMaterial.quantity.value = quantity
                        let newPhoto = Photo()
                        newPhoto.picture = photo?.picture
                        newPhoto.thumbNail = photo?.thumbNail
                        newPhoto.date = photo?.date ?? Date()
                        newMaterial.photo = newPhoto
                
                        project?.thaw()?.materials.insert(newMaterial, at: pos)
                        
                    } else {
                        let newMaterial = Material()
                        newMaterial.type = type
                        newMaterial.SKU = SKU
                        newMaterial.itemDescription = itemDescription
                        newMaterial.price.value = Double(price)
                        newMaterial.quantity.value = quantity
                        let newPhoto = Photo()
                        newPhoto.picture = photo?.picture
                        newPhoto.thumbNail = photo?.thumbNail
                        newPhoto.date = photo?.date ?? Date()
                        newMaterial.photo = newPhoto
                
                        project?.thaw()?.materials.insert(newMaterial, at: 0)
                    }
                }
                
            }
        }
    }
    
    
    
    func initData() {
        print(material)
        if let material = material {
            self.type = material.type ?? ""
            self.itemDescription = material.itemDescription ?? ""
            self.SKU = material.SKU ?? ""
            self.price = "\(material.price.value ?? 0.00)"
            self.photo = material.photo
            
        }
    }
}


struct MaterialItemView_Previews: PreviewProvider {
    static var previews: some View {
        MaterialItemView()
    }
}


struct MaterialItemView: View {
    
    var material: Material?
    
    var body: some View {
        if material != nil {
            HStack {
                AvatarThumbNailView(photo: material?.photo ?? Photo(), imageSize: 40)
                Spacer()
                
                VStack {
                    
                    Text(material?.type ?? "")
                        .font(.headline)
                        .minimumScaleFactor(0.50)
                    Text(material?.itemDescription ?? "")
                        .font(.subheadline)
                        .minimumScaleFactor(0.50)
                }
                
                Spacer()
                
                if material?.quantity.value != nil {
                    VStack {
                        Text("Quantity")
                            .font(.caption)
                            .minimumScaleFactor(0.50)
                        Text("\(material?.quantity.value ?? 0.0, specifier: "%g")")
                            .font(.caption)
                            .minimumScaleFactor(0.50)
                    }
                }
                
                VStack {
                    Text("SKU: \(material?.SKU ?? "")")
                        .font(.caption)
                        .minimumScaleFactor(0.50)
                    Text("Price: $\(material?.price.value ?? 0.0, specifier: "%g")")
                        .font(.caption)
                        .minimumScaleFactor(0.50)
                }
                .frame(maxWidth: 70)
            }
            .accentColor(.brandPrimary)
        }
        
    }
}


struct CompanyMaterialsList: View {
    @EnvironmentObject var state: AppState
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.realm) var publicRealm
    
    @ObservedResults(Company.self) var companies
    
    @State private var showAddMaterialsView: Bool = false
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State var material : Material?
    @State private var quantity = 0.0
    
    var project: Project?
    
    var company: Company? {
        return companies.first { company in
            company._id == state.user?.companyID
        }
    }
    
    var body: some View {
        
        VStack {
            if company != nil && company?.materials.count ?? 0 > 0 {
                List(company!.materials, id: \.self) { material in
                    MaterialItemView(material: material)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button {
                                // delete material if has permission
                                if state.canEditAndDelete {
                                    deleteMaterialFromCompanyList(material: material, company: self.company)
                                } else {
                                    alertTitle = "Sorry"
                                    alertMessage = "You don't have permission to delete this item."
                                    showingAlert = true
                                }
                                
                            } label: {
                                Image(systemName: "trash")
                            }
                            .tint(.red)
                            
                        }
                        .onTapGesture {
                            self.material = material
                            print(material)
                            self.showAddMaterialsView = true
                        }
                }
            } else {
                Text("Add materials by pressing the + button in the top right corner.")
                    .padding()
            }
        }
        .accentColor(.brandPrimary)
        .navigationTitle("Materials")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button(action: {
            self.material = nil
            self.showAddMaterialsView.toggle()
        }, label: {
            Image(systemName: "plus")
        }))
        .sheet(isPresented: $showAddMaterialsView) {
            AddMaterialView(company: company ?? Company(), material: self.$material, project: project)
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func addMaterialToJob(material: Material?) {
        let companyConfig =  app.currentUser!.configuration(partitionValue: "public=\(state.user?.companyID ?? "")")
        
        if let material = material {
            if project != nil {
                try! Realm(configuration: companyConfig).write {
                    if project!.materials.contains(material), let pos = project!.materials.firstIndex(of: material) {
                        project?.thaw()?.materials.remove(at: pos)
                        
                        let newMaterial = Material()
                        newMaterial.type = material.type
                        newMaterial.SKU = material.SKU
                        newMaterial.itemDescription = material.itemDescription
                        newMaterial.price = material.price
                    
                        
                        project?.thaw()?.materials.insert(newMaterial, at: 0)
                    } else {
                        
                        let newMaterial = Material()
                        newMaterial.type = material.type
                        newMaterial.SKU = material.SKU
                        newMaterial.itemDescription = material.itemDescription
                        newMaterial.price = material.price
                        
                        project?.thaw()?.materials.insert(newMaterial, at: 0)
                    }
                }
            }
        }
    }
    
    func addMaterialToCompany(material: Material?) {
        let publicConfig =  app.currentUser!.configuration(partitionValue: "public=public")
        
        try! Realm(configuration: publicConfig).write {
            if material  != nil && company != nil {
                if company!.materials.contains(material!), let pos = company!.materials.firstIndex(of: material!) {
                    company?.thaw()?.materials.remove(at: pos)
                    company?.thaw()?.materials.insert(material!, at: 0)
                    
                } else {
                    company?.thaw()?.materials.insert(material!, at: 0)
                }
            }
        }
    }
    
    func deleteMaterialFromCompanyList(material: Material?, company: Company?) {
        guard let material = material  else { return }
        guard let company = company else { return }
        
        if company.materials.contains(material), let pos = company.materials.firstIndex(of: material) {
            let publicConfig =  app.currentUser!.configuration(partitionValue: "public=public")
            
            try! Realm(configuration: publicConfig).write {
                company.thaw()?.materials.remove(at: pos)
            }
        }
    }
}

struct EditMaterialView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.realm) var publicRealm
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedRealmObject var company: Company
    
    var material: Material
    
    @State private var type = ""
    @State private var itemDescription = ""
    @State private var quantity = 0.0
    @State private var SKU = ""
    @State private var price = ""
    @State private var photo: Photo?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    
    var project: Project?

    var body: some View {
        VStack {
            Section(header: Text(material.type ?? "New Material")) {
                AvatarButton(photo: $photo, action: {})
                
                Form {
                    TextField(SKU.isEmpty ? "SKU" : SKU, text: $SKU)
                    TextField(type.isEmpty ? "Type" : type, text: $type)
                    TextField(itemDescription.isEmpty ? "Description" : itemDescription, text: $itemDescription)
                    
                    Section(header: Text("Price")) {
                        TextField(price.isEmpty ? "0.00" : price, text: $price)
                            .keyboardType(.numberPad)
                    }
                    if project != nil {
                        Section(header: Text("Quantity")) {
                            Stepper("\(quantity, specifier: "%g")", value: $quantity)
                        }
                    }
                }
            }
            
            CallToActionButton(title: "Add", action: {
                alertTitle = "Edit Material?"
                alertMessage = "The changes you've made will be saved for \(material.type ?? "this material")? "
                showingAlert = true
            })
            
                .padding()
        }
        .accentColor(.brandPrimary)
        .padding()
        .onAppear(perform: initData)
        .alert(isPresented: $showingAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), primaryButton:
                        .default(Text("Yes"), action: {
                addMaterialToCompany(material: material)
                addMaterialToJob(material: material)
            }),
                  secondaryButton: .default(Text("NO"), action: {
                
                self.presentationMode.wrappedValue.dismiss()
            }))
        }
    }
        func addMaterialToCompany(material: Material?) {
            try! publicRealm.write {
                if material  == nil  {
                    let newMaterial = Material()
                    newMaterial.type = type
                    newMaterial.SKU = SKU
                    newMaterial.itemDescription = itemDescription
                    newMaterial.price.value = Double(price)
                    let newPhoto = Photo()
                    newPhoto.picture = photo?.picture
                    newPhoto.thumbNail = photo?.thumbNail
                    newPhoto.date = photo?.date ?? Date()
                    newMaterial.photo = newPhoto
                    company.thaw()?.materials.insert(newMaterial, at: 0)
                } else {
                    if company.materials.contains(material!), let pos = company.materials.firstIndex(of: material!) {
                        company.thaw()?.materials.remove(at: pos)
                        let newMaterial = Material()
                        newMaterial.type = type
                        newMaterial.SKU = SKU
                        newMaterial.itemDescription = itemDescription
                        newMaterial.price.value = Double(price)
                        let newPhoto = Photo()
                        newPhoto.picture = photo?.picture
                        newPhoto.thumbNail = photo?.thumbNail
                        newPhoto.date = photo?.date ?? Date()
                        newMaterial.photo = newPhoto
                        company.thaw()?.materials.insert(newMaterial, at: pos)
                        
                    }
                }
            }
        }
        
        func addMaterialToJob(material: Material?) {
            let companyConfig =  app.currentUser!.configuration(partitionValue: "public=\(state.user?.companyID ?? "")")
            
            if project != nil {
                try! Realm(configuration: companyConfig).write {
                    if material == nil {
                        
                        let newMaterial = Material()
                        newMaterial.type = type
                        newMaterial.SKU = SKU
                        newMaterial.itemDescription = itemDescription
                        newMaterial.price.value = Double(price)
                        newMaterial.quantity.value = quantity
                        let newPhoto = Photo()
                        newPhoto.picture = photo?.picture
                        newPhoto.thumbNail = photo?.thumbNail
                        newPhoto.date = photo?.date ?? Date()
                        newMaterial.photo = newPhoto
                
                        project?.thaw()?.materials.insert(newMaterial, at: 0)
                    } else {
                        if project!.materials.contains(material!), let pos = project!.materials.firstIndex(of: material!) {
                            project?.thaw()?.materials.remove(at: pos)
                            
                            let newMaterial = Material()
                            newMaterial.type = type
                            newMaterial.SKU = SKU
                            newMaterial.itemDescription = itemDescription
                            newMaterial.price.value = Double(price)
                            newMaterial.quantity.value = quantity
                            let newPhoto = Photo()
                            newPhoto.picture = photo?.picture
                            newPhoto.thumbNail = photo?.thumbNail
                            newPhoto.date = photo?.date ?? Date()
                            newMaterial.photo = newPhoto
                    
                            project?.thaw()?.materials.insert(newMaterial, at: pos)
                            
                        } else {
                            let newMaterial = Material()
                            newMaterial.type = type
                            newMaterial.SKU = SKU
                            newMaterial.itemDescription = itemDescription
                            newMaterial.price.value = Double(price)
                            newMaterial.quantity.value = quantity
                            let newPhoto = Photo()
                            newPhoto.picture = photo?.picture
                            newPhoto.thumbNail = photo?.thumbNail
                            newPhoto.date = photo?.date ?? Date()
                            newMaterial.photo = newPhoto
                    
                            project?.thaw()?.materials.insert(newMaterial, at: 0)
                        }
                    }
                    
                }
            }
        }
        
        
        
        func initData() {
            print(material)
            
                self.type = material.type ?? ""
                self.itemDescription = material.itemDescription ?? ""
                self.SKU = material.SKU ?? ""
                self.price = "\(material.price.value ?? 0.00)"
                self.photo = material.photo
                if project != nil {
                    self.quantity = material.quantity.value ?? 0.0
                    
                }
            }
    
}
