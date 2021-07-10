//
//  RulesView.swift
//  ProxyFace (macOS)
//
//  Created by oymiss on 28/6/2021.
//

import SwiftUI

struct RuleRowView: View{
    @ObservedObject var item: RuleViewModel
    var isSelected: Bool = false
    var nodeListViewModel: NodeListViewModel = NodeListViewModel.shared
    var body: some View {
        
        HStack {
            VStack(alignment: .leading) {
                Text(item.name)
                Text(item.type).font(.footnote).foregroundColor(.secondary)
            }
            Spacer()
            Text(item.endpoint).foregroundColor(.secondary)

        }
        .onHover { isHovered in
            item.showingPopoverButton = isHovered
        }
    }
}

struct RulesView: View {
    @State var selectItems: Set<RuleViewModel> = []
    @State var showingAddRule: Bool = false
    @State var showingDeleteRule: Bool = false
    @StateObject var listViewModel: RuleListViewModel = RuleListViewModel.shared

    func deleteRule(id: UUID) {
        listViewModel.items.removeAll { item in
            item.id == id
        }
    }
    
    var body: some View {

        List(selection: $selectItems) {
            ForEach(listViewModel.items, id: \.self) { item in
                RuleRowView(item: item, isSelected: selectItems.contains(item))
            }
        }
        .sheet(isPresented: $showingAddRule) {
            AddRuleView().environmentObject(listViewModel)
        }
        .alert(isPresented: $showingDeleteRule) {
            Alert(title: Text("Do you really want to delete \(selectItems.count == 1 ? "this rule" : "these rules")?"),
                  primaryButton: .default(Text("Delete"), action: {
                    for item in selectItems {
                        deleteRule(id: item.id)
                    }
                    print("delete!")
                    selectItems.removeAll()
                    saveClashConfig()
                  }),
                  secondaryButton: .cancel({})
            )
        }
        .navigationTitle("Rules")
        .toolbar(content: {
            ToolbarItem {
                Button {
                    showingDeleteRule = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(selectItems.count >= 1 ? .red : .gray)
                }
                .keyboardShortcut(.delete, modifiers: [])
                .disabled(selectItems.isEmpty)
            }
            ToolbarItem {
                Button {
                    showingAddRule = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.blue)
                }
            }
        })
        
    }
}

struct RuleContentView_Previews: PreviewProvider {
    static var previews: some View {
        RulesView()
    }
}
