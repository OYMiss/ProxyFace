//
//  NodeViewModel.swift
//  ProxyFace (macOS)
//
//  Created by oymiss on 2/7/2021.
//

import Foundation

class NodeViewModel: Identifiable, Hashable, ObservableObject {
    internal init(name: String, type: String) {
        self.name = name
        self.type = type
    }
    
    static func == (lhs: NodeViewModel, rhs: NodeViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        return hasher.combine(ObjectIdentifier(self))
    }
    
    init(endPointitem: EndPointViewModel) {
        self.name = endPointitem.name
        self.type = "endpoint"
    }
    
    init(proxyItem: ProxyViewModel) {
        self.name = proxyItem.name
        self.type = "proxy"
    }
    
    var id = UUID()
    @Published var name: String
    @Published var type: String
    @Published var checkedFlag: Bool = false
}

class NodeListViewModel: ObservableObject {

    @Published var endpointViewItems: [NodeViewModel]
    @Published var proxyViewItems: [NodeViewModel]
    @Published var buildinViewItems: [NodeViewModel]
    
    static var shared = NodeListViewModel()
    
    func getValidNodeName(nodeName: String) -> String {
        var validNodeName = nodeName
        var cnt = 1
        while NodeListViewModel.shared.isExistNodeName(nodeName: validNodeName) {
            validNodeName = nodeName + "(\(cnt))"
            cnt += 1
        }
        return validNodeName
    }
    
    func isExistNodeName(nodeName: String) -> Bool {
        return
            buildinViewItems.contains { nodeViewModel in
                nodeViewModel.name == nodeName
            } ||
            endpointViewItems.contains { nodeViewModel in
                nodeViewModel.name == nodeName
            } ||
            proxyViewItems.contains { nodeViewModel in
                nodeViewModel.name == nodeName
            }
    }
    
    func rename(oldName: String, newName: String) {
        for item in endpointViewItems {
            if item.name == oldName {
                item.name = newName
            }
        }
        for item in proxyViewItems {
            if item.name == oldName {
                item.name = newName
            }
        }
    }
    
    func remove(byName: Set<String>) {
        endpointViewItems.removeAll { endpointViewItem in
            byName.contains(endpointViewItem.name)
        }
        proxyViewItems.removeAll { proxyViewItem in
            byName.contains(proxyViewItem.name)
        }
    }
    
    func add(proxyViewModel: ProxyViewModel) {
        self.proxyViewItems.append(NodeViewModel(proxyItem: proxyViewModel))
    }
    
    func add(endpointViewModel: EndPointViewModel) {
        self.endpointViewItems.append(NodeViewModel(endPointitem: endpointViewModel))
    }
    
    private init() {
        self.buildinViewItems = [NodeViewModel(name: "DIRECT", type: "buildin"),
                                 NodeViewModel(name: "REJECT", type: "buildin")]
        endpointViewItems = []
        proxyViewItems = []
        
        let pItems = ProxyListViewModel.shared.items
        let eItems = EndPointListViewModel.shared.items
        endpointViewItems.removeAll()
        proxyViewItems.removeAll()
        for item in eItems {
            let nitem = NodeViewModel(endPointitem: item)
            endpointViewItems.append(nitem)
        }
        
        for item in pItems {
            let nitem = NodeViewModel(proxyItem: item)
            proxyViewItems.append(nitem)
        }
    }
}

