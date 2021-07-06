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
    @Published var items: [NodeViewModel]
    
    static var shared = NodeListViewModel()
    
    func refresh() {
        let pItems = ProxyListViewModel.shared.items
        let eItems = EndPointListViewModel.shared.items
        items.removeAll()
        endpointViewItems.removeAll()
        proxyViewItems.removeAll()
        items.append(contentsOf: self.buildinViewItems)
        for item in eItems {
            let nitem = NodeViewModel(endPointitem: item)
            items.append(nitem)
            endpointViewItems.append(nitem)
        }
        
        for item in pItems {
            let nitem = NodeViewModel(proxyItem: item)
            proxyViewItems.append(nitem)
            items.append(nitem)
        }
    }
    
    private init() {
        self.buildinViewItems = [NodeViewModel(name: "DIRECT", type: "buildin"),
                                 NodeViewModel(name: "REJECT", type: "buildin")]
        items = []
        endpointViewItems = []
        proxyViewItems = []
        self.refresh()
    }
}

