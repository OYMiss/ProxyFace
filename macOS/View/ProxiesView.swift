//
//  ProxiesView.swift
//  ProxyFace (macOS)
//
//  Created by oymiss on 28/6/2021.
//

import SwiftUI

struct ProxyRowView: View {
    @ObservedObject var item: ProxyViewModel
    var isSelected: Bool = false
    @State var oldProxyName = ""
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.name)
                Text(item.type).font(.footnote).foregroundColor(.secondary).frame(alignment: .topLeading)
            }
            Spacer()
            Text(item.status).foregroundColor(.secondary)
            Image(systemName: "info.circle").foregroundColor(isSelected ? .white : .accentColor).onTapGesture {
                item.showingPopover = true
                oldProxyName = item.name
            }
            .popover(isPresented: $item.showingPopover, arrowEdge: Edge.trailing) {
                ProxyDetailView(item: item)
                    .frame(width: 220)
                    .padding()
                    .onDisappear() {
                        print("on disapper")
                        if item.name != oldProxyName {
                            EndPointListViewModel.shared.renameNodes(oldName: oldProxyName, newName: item.name)
                            NodeListViewModel.shared.rename(oldName: oldProxyName, newName: item.name)
                        }
                        saveClashConfigToNewConfig()
                    }
            }
        }
    }
}

struct ProxiesView: View {
    @State var selectItems: Set<ProxyViewModel> = []
    @State var showingAddProxy: Bool = false
    @State var showingDeleteProxy: Bool = false
    @State var showingAlert: Bool = false
    @StateObject var listViewModel: ProxyListViewModel = ProxyListViewModel.shared
    
    func deleteProxy(id: UUID) {
        listViewModel.items.removeAll { item in
            item.id == id
        }
        print("delete!")
    }
        
    var body: some View {
        VStack {
            List(selection: $selectItems) {
                ForEach(listViewModel.items, id: \.self) { item in
                    ProxyRowView(item: item, isSelected: selectItems.contains(item))
                }
            }
        }
        .sheet(isPresented: $showingAddProxy) {
            AddProxyView().environmentObject(listViewModel)
        }
        .alert(isPresented: $showingDeleteProxy) {
            Alert(title: Text("Do you really want to delete \(selectItems.count == 1 ? "this proxy" : "these proxies")?"),
                  primaryButton: .default(Text("Delete"), action: {
                    var byName: Set<String> = []
                    for item in selectItems {
                        deleteProxy(id: item.id)
                        byName.insert(item.name)
                    }
                    print("delete!")
                    selectItems.removeAll()
                    NodeListViewModel.shared.remove(byName: byName)
                    EndPointListViewModel.shared.removeNodes(byName: byName)
                    saveClashConfigToNewConfig()
                  }),
                  secondaryButton: .cancel({})
            )
        }
        .navigationTitle("Proxies")
        .toolbar(content: {
            ToolbarItem {
                Button {
                    var isUsing = false
                    for item in selectItems {
                        if EndPointListViewModel.shared.isUsing(proxyName: item.name) {
                            isUsing = true
                        }
                    }
                    
                    if isUsing {
                        showingAlert = true
                    } else {
                        showingDeleteProxy = true
                    }
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(selectItems.count >= 1 ? .red : .gray)
                }
                .keyboardShortcut(.delete, modifiers: [])
                .disabled(selectItems.isEmpty)
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Some endpoints are using selected proxies."),
                          dismissButton: .default(Text("Got it")))
                }
            }
            ToolbarItem {
                Button {
                    showingAddProxy = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.blue)
                }
            }

        })
        
    }
}

struct ProxiesContentView_Previews: PreviewProvider {
    static var previews: some View {
        ProxiesView()
    }
}
