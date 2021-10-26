//
//  CompactCardView.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 5/3/21.
//

import SwiftUI
import RealmSwift

struct CompactCardView: View {
    
    @EnvironmentObject var state: AppState
    @Environment(\.realm) var publicRealm
    
    @ObservedResults(Project.self) var projects
    @ObservedRealmObject var project: Project
    
    @State private var category = ""
    @State var showingDetailSheet = false
    
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
        
        VStack {
            HStack {
                NeighborhoodView(project: project)
                Spacer()
                Text(project.category)
//                Text(category)
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
            }.padding()
            
            Text(project.client)
                .font(.title)
            Text(project.name ?? project.client)
                .font(.subheadline)
            HStack {
                Image(systemName: "list.dash")
                if project.activity.count > 0 {
                    Image(systemName: "bubble.right")
                    Text(getClientCommentCount())
                        .font(.caption)
                }
                if project.crew.count > 0 {
                    Image(systemName: "person")
                    Text("\(project.crew.count)")
                        .font(.caption)
                }
                if project.todo.count > 0 {
                    Image(systemName: "text.badge.checkmark")
                    Text(getTodoCount())
                        .font(.caption)
                }
            }
            .padding()
            .sheet(isPresented: $showingDetailSheet, content: {
                ProjectCardView(project: project)
            })
        }
        .background(LinearGradient(gradient: Gradient(colors: [labelColor, Color(UIColor.secondarySystemBackground)]), startPoint: .top, endPoint: .bottom)
                        .cornerRadius(10))
        .onTapGesture {
            showingDetailSheet = true
        }
        .onAppear {
            withAnimation {
                self.category = project.categoryState.asString
            }
        }
    }
    
    func getClientCommentCount() -> String {
        let comments = project.activity.filter(NSPredicate(format: "type CONTAINS[c] %@", "comment"))
        return "\(comments.count)"
    }
    
    func getTodoCount() -> String {
        let completed = project.todo.filter(NSPredicate(format: "complete == %d", true)).count
        let total = project.todo.count
        
        return "\(completed)/\(total)"
    }
}

//struct CompactCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        CompactCardView()
//    }
//}
