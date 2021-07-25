//
//  EndPointDetailView.swift
//  ProxyFace (macOS)
//
//  Created by oymiss on 1/7/2021.
//

import SwiftUI

struct EndPointDetailView: View {
    @ObservedObject var item: EndPointViewModel
    @StateObject var nodeListViewModel: NodeListViewModel
    var listWidth: CGFloat = 220
    @State var checked = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                TextField("", text: $item.name)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.title2)
                    .disabled(EndPointListViewModel.shared.isUsing(proxyName: item.name) || RuleListViewModel.shared.isUsing(endpointName: item.name))
            }
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        Toggle(isOn: $item.showingBuildinNodes) {
                            Label("Buildin", systemImage: "gearshape")
                        }
                        .disabled(nodeListViewModel.buildinViewItems.contains(where: { nodeViewModel in
                            nodeViewModel.name == item.proxy
                        }))
                        .foregroundColor(.gray)
                        
                        ForEach(Array(zip(nodeListViewModel.buildinViewItems.indices, nodeListViewModel.buildinViewItems)), id: \.1) { i, proxyItem in
                            Toggle(isOn: $nodeListViewModel.buildinViewItems[i].checkedFlag) {
                                Text(proxyItem.name)
                                    .foregroundColor(.primary)
                            }
                            .disabled(item.proxy == proxyItem.name)
                            .toggleStyle(CheckboxToggleStyle())
                            .onChange(of: nodeListViewModel.buildinViewItems[i].checkedFlag, perform: { value in
                                if value {
                                    if !item.nodes.contains(proxyItem.name) {
                                        item.nodes.append(proxyItem.name)
                                    }
                                    item.objectWillChange.send()
                                } else {
                                    item.nodes.removeAll { s in
                                        s == proxyItem.name
                                    }
                                    item.objectWillChange.send()
                                }
                            })
                        }.existWhen(item.showingBuildinNodes)
                    }
                    
                    Divider().padding(.bottom, 4).padding(.top, 4)

                    VStack(alignment: .leading) {
                        Toggle(isOn: $item.showingEndpoints) {
                            Label("EndPoints", systemImage: "bolt")
                        }
                        .disabled(nodeListViewModel.endpointViewItems.contains(where: { nodeViewModel in
                            nodeViewModel.name == item.proxy
                        }))
                        .foregroundColor(.gray)
                        
                        ForEach(Array(zip(nodeListViewModel.endpointViewItems.indices, nodeListViewModel.endpointViewItems)), id: \.1) { i, proxyItem in
                            Toggle(isOn: $nodeListViewModel.endpointViewItems[i].checkedFlag) {
                                Text(proxyItem.name)
                                    .foregroundColor(.primary)
                            }
                            .disabled(item.proxy == proxyItem.name)
                            .toggleStyle(CheckboxToggleStyle())
                            .onChange(of: nodeListViewModel.endpointViewItems[i].checkedFlag, perform: { value in
                                if value {
                                    
                                    if !item.nodes.contains(proxyItem.name) {
                                        item.nodes.append(proxyItem.name)
                                    }
                                    item.objectWillChange.send()
                                } else {
                                    item.nodes.removeAll { s in
                                        s == proxyItem.name
                                    }
                                    item.objectWillChange.send()
                                }
                            })
                        }.existWhen(item.showingEndpoints)
                    }
   
                    
                    Divider().padding(.bottom, 4).padding(.top, 4)
                    VStack(alignment: .leading) {
                        Toggle(isOn: $item.showingProxies) {
                            Label("Proxies", systemImage: "square.stack.3d.up")
                        }
                        .disabled(nodeListViewModel.proxyViewItems.contains(where: { nodeViewModel in
                            nodeViewModel.name == item.proxy
                        }))
                        .foregroundColor(.gray)
                        ForEach(Array(zip(nodeListViewModel.proxyViewItems.indices, nodeListViewModel.proxyViewItems)), id: \.1) { i, proxyItem in
                            Toggle(isOn: $nodeListViewModel.proxyViewItems[i].checkedFlag) {
                                Text(proxyItem.name)
                                    .foregroundColor(.primary)
                            }
                            .disabled(item.proxy == proxyItem.name)
                            .toggleStyle(CheckboxToggleStyle())
                            .onChange(of: nodeListViewModel.proxyViewItems[i].checkedFlag, perform: { value in
                                if value {
                                    if !item.nodes.contains(proxyItem.name) {
                                        item.nodes.append(proxyItem.name)
                                    }
                                    item.objectWillChange.send()
                                } else {
                                    item.nodes.removeAll { s in
                                        s == proxyItem.name
                                    }
                                    item.objectWillChange.send()
                                }
                            })
                        }.existWhen(item.showingProxies)
                    }
                    
                }.frame(width: listWidth, alignment: .leading)
            }
        }
    }
}

struct EndPointDetailView_Previews: PreviewProvider {
    @State static var checkedProxy: Set<String> = []
    
    static var previews: some View {
        let item = EndPointItem(name: "Proxy", proxy: "HongKong IPLC 01", proxies: ["HongKong IPLC 01", "HongKong IPLC 02", "Direct", "Reject"])
        let viewItem = EndPointViewModel(item)
        EndPointDetailView(item: viewItem, nodeListViewModel: NodeListViewModel.shared)
    }
}
