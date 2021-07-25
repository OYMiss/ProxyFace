//
//  EndpointsView.swift
//  ProxyFace (macOS)
//
//  Created by oymiss on 1/7/2021.
//

import SwiftUI

// for picker of endpoints
// using onChange or onChange may cause bug
// https://stackoverflow.com/questions/57518852/swiftui-picker-onchange-or-equivalent
extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        return Binding(
            get: { self.wrappedValue },
            set: { selection in
                self.wrappedValue = selection
                handler(selection)
        })
    }
}

struct EndPointRowView: View {
    @ObservedObject var item: EndPointViewModel
    var isSelected: Bool = false
    @StateObject var nodeListViewModel: NodeListViewModel = NodeListViewModel.shared
    @State var oldEndpointName = ""
    
    var body: some View {
        HStack {
            Text(item.name)
            
            Spacer()
            // use extension of binding
            Picker("", selection: $item.proxy.onChange({ proxy in
                item.changeEndPointTo(endPointName: item.name, proxyName: proxy)
                NSLog("change proxy of \(item.name) to \(proxy)")
            })) {
                ForEach(Array(item.nodes), id: \.self) { proxyName in
                    Text(proxyName)
                }
            }
            .disabled(item.disablePicker)
            // bug here!
//            .onChange(of: item.proxy, perform: { proxy in
//                item.changeEndPointTo(endPointName: item.name, proxyName: proxy)
//                NSLog("change proxy of \(item.name) to \(proxy)")
//            })
            // also have bug!
//            .onReceive(Just(item.proxy)) {
//                NSLog("Selected: \($0)")
//            }
            .frame(width: 128)
            .alert(isPresented: $item.showConfigChangedAlert) {
                Alert(title: Text("Config changed"),
                      message: Text("When config is changed, you should restart core."),
                      primaryButton: .default(Text("Restart"), action: {
                        StopClash()
                        StartClash()
                        sleep(1)
                        NSLog("retry change proxy of \(item.name) to \(item.lastErrorProxyName)")
                        item.changeEndPointTo(endPointName: item.name, proxyName: item.lastErrorProxyName)
                      }),
                      secondaryButton: .default(Text("OK")))
            }
            Image(systemName: "info.circle").font(.title3).foregroundColor(isSelected ? .white : .blue)
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
                                item.name = NodeListViewModel.shared.getValidNodeName(nodeName: item.name)
                                EndPointListViewModel.shared.renameNodes(oldName: oldEndpointName, newName: item.name)
                                NodeListViewModel.shared.rename(oldName: oldEndpointName, newName: item.name)
                            }
                            saveClashConfig()
                        }
                }
        }
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
            Alert(title: Text("Do you really want to delete \(selectItems.count == 1 ? "this endpoint" : "these endpoints")?"),
                  primaryButton: .default(Text("Delete"), action: {
                    var byName: Set<String> = []
                    for item in selectItems {
                        deleteEndPoint(id: item.id)
                        NSLog("delete endpoint which name = \(item.name)")
                        byName.insert(item.name)
                    }
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
                            favoriteListViewModel.endpointViewItems.append(item)
                            saveUserConfig()
                        }
                    }
                    
                    selectItems.removeAll()
                } label: {
                    Image(systemName: "heart")
                        .foregroundColor(selectItems.count >= 1 ? .blue : .gray)
                }
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
