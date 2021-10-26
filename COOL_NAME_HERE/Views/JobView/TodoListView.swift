//
//  TodoListView.swift
//  TodoListView
//
//  Created by Hayden Davidson on 9/21/21.
//

import SwiftUI
import RealmSwift

struct TodoListView: View {
    @EnvironmentObject var state: AppState
    
    @State private var showingTodoList = false
    
    @ObservedRealmObject var project: Project
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                
                Label("Show Todos", systemImage: "text.badge.checkmark")
                Spacer()
                Toggle("Show Todos", isOn: withAnimation{ $showingTodoList })
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: Color.brandPrimary))
                
            }
            if showingTodoList {
                HStack {
                    Spacer()
                    if state.canAddClient {
                        NavigationLink(destination: AddTodoItemView(project: project)
                                        .accentColor(.brandPrimary)
                                        .environment(\.realmConfiguration,
                                                      app.currentUser!.configuration(partitionValue: "public=\(state.user?.companyID ?? "")"))
                        ) {
                            Image(systemName: "plus")
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                if project.todo.count > 0 {
                    ForEach(project.todo, id: \._id) { item  in
                        TodoItemView(item: item, project: project)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
}

//MARK: - Add TODO ITEM VIEW

struct AddTodoItemView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.realm) var companyRealm
    @ObservedRealmObject var project: Project
    
    @State private var itemName = ""
    @State private var onHand = 0
    @State private var needed = 0
    @State private var addQuantity = false
    
    var body : some View {
        Form {
            Section(header: Text("Description")) {
                TextEditor(text: $itemName)
                    .frame(height: 100)
//                    .padding(.horizontal, 5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8.0)
                            .stroke(Color.secondary, lineWidth: 1)
                    )
//                    .padding(.horizontal)
            }
            
            Section(header: Text("Do you need more than one?")) {
                Toggle("Add more than one of these items.", isOn: $addQuantity)
                    .labelsHidden()
                if addQuantity {
//                    Stepper("On Hand \(item.onHand.value ?? 0)", value: $onHand)
                    Stepper("Needed: \(needed)", value: $needed)
                }
            }
            
            CallToActionButton(title: "Add") {
                addTodoItem()
            }
        }
        .navigationBarTitle("New Todo Item")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func addTodoItem() {
        // add todo item to project todo list
        try! companyRealm.write {
            let newItem = TodoItem()
            
            newItem.name = itemName
            if onHand > 0 {
                newItem.onHand.value = onHand
            }
            newItem.needed.value = needed
            newItem.dateCreated = Date()
//            if onHand == needed && needed != 0 {
//                newItem.complete = true
//            }
            
            $project.todo.append(newItem)
        }
    }
}


//MARK: - TODO ITEM View
struct TodoItemView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.realm) var companyRealm
    
    @ObservedRealmObject var item: TodoItem
    @ObservedRealmObject var project: Project
    
    @State private var onHandCount = 0
    
    
    
    var body: some View {
        HStack {
            Image(systemName: item.complete ? "checkmark.circle" : "circle")
                .onTapGesture(perform: complete)
            Text(item.name)
            if item.onHand.value ?? 0 > 0 && item.needed.value ?? 0 > 0 {
                Text("\(item.onHand.value ?? 0)/\(item.needed.value ?? 0)")
            }
            if !item.complete && item.needed.value ?? 0 > 0 {
                Stepper {
                    Text("\(item.onHand.value ?? 0)/\(item.needed.value ?? 0)")
                } onIncrement: {
                    incrOnHand()
                } onDecrement: {
                    decrOnHand()
                }
                .labelsHidden()

            } 
        }
        .contextMenu(ContextMenu(menuItems: {
            Button(role: .destructive) {
                withAnimation {
                    removeToDoItem()
                }
                
            } label: {
                Label("Remove item", systemImage: "trash")
            }

            
        }))
        .onAppear(perform: initData)
        
        
        
    }
    func removeToDoItem() {
        try! companyRealm.write {
            if project.todo.contains(item), let pos = project.todo.firstIndex(of: item) {
                project.thaw()?.todo.remove(at: pos)
            }
            
        }
    }
    
    func complete() {
        try! companyRealm.write {
            let item = project.todo.first { todoItem in
                todoItem == self.item
            }
            
            
            if item?.needed.value ?? 0 == 0 {
                item?.thaw()?.complete.toggle()
            }
        }
    }
    
    func incrOnHand() {
        if onHandCount < item.needed.value ?? 0 {
            onHandCount += 1
        }
        saveOnHandQuantity()
    }
    
    func decrOnHand() {
        if onHandCount > 0 {
            onHandCount -= 1
        }
        saveOnHandQuantity()
    }
    
    
    func saveOnHandQuantity() {
        // write changes of on hand count to todoItem

            print("writing to realm")
            try! companyRealm.write {
                let item = project.todo.first { todoItem in
                    todoItem == self.item
                }
                
                item?.thaw()?.onHand.value = onHandCount
                if onHandCount == item?.needed.value {
                    item?.thaw()?.complete = true
                }

        }
    }
    
    func initData() {
        self.onHandCount = item.onHand.value ?? 0
    }
        
}


//MARK: - Preview
//struct TodoListView_Previews: PreviewProvider {
//    static var previews: some View {
//        TodoListView()
//    }
//}
