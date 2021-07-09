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
    @State var oldEndpointName = ""
    
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
                    oldEndpointName = item.name
                    item.showingPopover = true
                    item.showingProxies = false
                    item.showingEndpoints = false
                    item.showingBuildinNodes = false
                    for viewModel in nodeListViewModel.buildinViewItems {
                        viewModel.checkedFlag = item.nodes.contains(viewModel.name)
                        if !item.showingBuildinNodes && viewModel.checkedFlag {
                            item.showingBuildinNodes = true
                        }
                    }
                    for viewModel in nodeListViewModel.endpointViewItems {
                        viewModel.checkedFlag = item.nodes.contains(viewModel.name)
                        if !item.showingEndpoints && viewModel.checkedFlag {
                            item.showingEndpoints = true
                        }
                    }
                    for viewModel in nodeListViewModel.proxyViewItems {
                        viewModel.checkedFlag = item.nodes.contains(viewModel.name)
                        if !item.showingProxies && viewModel.checkedFlag {
                            item.showingProxies = true
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
                            if oldEndpointName != item.name {
                                EndPointListViewModel.shared.renameNodes(oldName: oldEndpointName, newName: item.name)
                                NodeListViewModel.shared.rename(oldName: oldEndpointName, newName: item.name)
                            }
                            saveClashConfig()
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
    @State var alertInfo = ""
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
                    var byName: Set<String> = []
                    for item in selectItems {
                        deleteEndPoint(id: item.id)
                        byName.insert(item.name)
                    }
                    print("delete!")
                    selectItems.removeAll()
                    EndPointListViewModel.shared.removeNodes(byName: byName)
                    NodeListViewModel.shared.remove(byName: byName)
                    listViewModel.objectWillChange.send()
                    saveClashConfig()
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
                    var isUsingByRule = false
                    var isUsingByEndpoint = false
                    for item in selectItems {
                        if RuleListViewModel.shared.isUsing(endpointName: item.name) {
                            isUsingByRule = true
                        }
                        if EndPointListViewModel.shared.isUsing(proxyName: item.name) {
                            isUsingByEndpoint = true
                        }
                    }
                    
                    if isUsingByEndpoint {
                        alertInfo = "Some endpoints are using selected endpoints."
                        showingAlert = true
                    } else if isUsingByRule {
                        alertInfo = "Some rules are using selected endpoints."
                        showingAlert = true
                    } else {
                        showingDeleteEndPoint = true
                    }
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(selectItems.count >= 1 ? .red : .gray)
                }
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text(alertInfo),
                          dismissButton: .default(Text("Got it")))
                }
                .keyboardShortcut(.delete, modifiers: [])
                .disabled(selectItems.isEmpty)
            }
            ToolbarItem {
                Button {
                    for viewModel in NodeListViewModel.shared.buildinViewItems {
                        viewModel.checkedFlag = false
                    }
                    for viewModel in NodeListViewModel.shared.endpointViewItems {
                        viewModel.checkedFlag = false
                    }
                    for viewModel in NodeListViewModel.shared.proxyViewItems {
                        viewModel.checkedFlag = false
                    }
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
