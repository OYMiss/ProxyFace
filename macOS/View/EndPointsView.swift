//
//  EndpointsView.swift
//  ProxyFace (macOS)
//
//  Created by oymiss on 1/7/2021.
//

import SwiftUI

struct EndPointRowView: View {
    @ObservedObject var item: EndPointViewModel
    var isSelected: Bool = false
    @StateObject var nodeListViewModel: NodeListViewModel = NodeListViewModel.shared

    var body: some View {
        HStack {
            Text(item.name)
            
            Spacer()
            Picker("", selection: $item.proxy) {
                ForEach(Array(item.nodes), id: \.self) { proxyName in
                    Text(proxyName)
                }
            }
            .onChange(of: item.proxy, perform: { proxy in
                changeEndPointTo(endPointName: item.name, proxyName: proxy)
                print("Changed to \(proxy)")
            })
            .frame(width: 128)
            Image(systemName: "info.circle").font(.title3).foregroundColor(isSelected ? .white : .blue)
//                .visiableWhen(item.showingPopoverButton)
                .onTapGesture {
                    item.showingPopover = true
                    item.showingProxies = false
                    item.showingEndpoints = false
                    item.showingBuildinNodes = false
                    
                    for nodeViewModel in nodeListViewModel.items {
                        nodeViewModel.checkedFlag = item.nodes.contains(nodeViewModel.name)
                        if (nodeViewModel.checkedFlag) {
                            if !item.showingProxies && nodeViewModel.type == "proxy" {
                                item.showingProxies = true
                            }
                            if !item.showingEndpoints && nodeViewModel.type == "endpoint" {
                                item.showingEndpoints = true
                            }
                            if !item.showingBuildinNodes && nodeViewModel.type == "buildin" {
                                item.showingBuildinNodes = true
                            }
                        }
                    }
                }
                .popover(isPresented: $item.showingPopover, arrowEdge: Edge.trailing) {
                    EndPointDetailView(item: item, nodeListViewModel: nodeListViewModel)
                        .frame(width: 220, height: 240)
                        .padding()
                        .onDisappear() {
                            print("endpoint popover on disapper")
                            item.nodes.removeAll { nodeName in
                                (!item.showingBuildinNodes && nodeListViewModel.buildinViewItems.contains(where: { node in
                                    node.name == nodeName
                                })) ||
                                (!item.showingProxies && nodeListViewModel.proxyViewItems.contains(where: { node in
                                    node.name == nodeName
                                })) ||
                                (!item.showingEndpoints && nodeListViewModel.endpointViewItems.contains(where: { node in
                                    node.name == nodeName
                                }))
                            }
                            NodeListViewModel.shared.refresh()
                            saveClashConfigToNewConfig()
                        }
                }
        }
//        .onHover { isHovered in
//            item.showingPopoverButton = isHovered
//        }
    }
}

struct EndPointsView: View {
    @State var selectItems: Set<EndPointViewModel> = []
    @State var showingAddEndPoint: Bool = false
    @State var showingDeleteEndPoint: Bool = false
    @State var showingAlert: Bool = false
    @StateObject var listViewModel: EndPointListViewModel = EndPointListViewModel.shared
    @StateObject var favoriteListViewModel: FavoriteListViewModel = FavoriteListViewModel.shared

    func deleteEndPoint(id: UUID) {
        listViewModel.items.removeAll { item in
            item.id == id
        }
    }
    
    var body: some View {
        List(selection: $selectItems) {
            ForEach(listViewModel.items, id: \.self) { item in
                EndPointRowView(item: item, isSelected: selectItems.contains(item))
            }
        }
        .sheet(isPresented: $showingAddEndPoint) {
            AddEndPointView().environmentObject(listViewModel)
        }
        .alert(isPresented: $showingDeleteEndPoint) {
            Alert(title: Text("Do you really want to delete \(selectItems.count == 1 ? "this proxy" : "these proxies")?"),
                  primaryButton: .default(Text("Delete"), action: {
                    for item in selectItems {
                        deleteEndPoint(id: item.id)
                    }
                    print("delete!")
                    selectItems.removeAll()
                    NodeListViewModel.shared.refresh()
                    listViewModel.objectWillChange.send()
                    saveClashConfigToNewConfig()
                  }),
                  secondaryButton: .cancel({})
            )
        }
        .navigationTitle("EndPoints")
        .toolbar(content: {
            ToolbarItem {
                Button {
                    for item in selectItems {
                        if !favoriteListViewModel.endpointViewItems.contains(item) {
                            favoriteListViewModel.endpointViewItems.insert(item)
                            saveUserConfig()
                        }
                    }
                    
                    selectItems.removeAll()
                } label: {
                    Image(systemName: "heart")
                        .foregroundColor(selectItems.count >= 1 ? .blue : .gray)
                }
                .keyboardShortcut(.delete, modifiers: [])
                .disabled(selectItems.isEmpty)
            }
            ToolbarItem {
                Button {
                    var isUsing = false
                    for item in selectItems {
                        if RuleListViewModel.shared.isUsing(endpointName: item.name) {
                            isUsing = true
                        }
                    }
                    if isUsing {
                        showingAlert = true
                    } else {
                        showingDeleteEndPoint = true
                    }
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(selectItems.count >= 1 ? .red : .gray)
                }
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Can not delete! \nSome endpoints are using by rule."),
                          dismissButton: .default(Text("Got it")))
                }
                .keyboardShortcut(.delete, modifiers: [])
                .disabled(selectItems.isEmpty)
            }
            ToolbarItem {
                Button {
                    showingAddEndPoint = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.blue)
                }
            }
        })
    }
}

struct EndPointsView_Previews: PreviewProvider {
    static var previews: some View {
        EndPointsView()
    }
}
