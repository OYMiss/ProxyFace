//
//  EndPointViewModel.swift
//  ProxyFace (macOS)
//
//  Created by oymiss on 1/7/2021.
//

import Foundation
import Combine

class EndPointViewModel: Identifiable, Hashable, ObservableObject {
    // Todo
    static func == (lhs: EndPointViewModel, rhs: EndPointViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        return hasher.combine(ObjectIdentifier(self))
    }
    
    internal init(_ item: EndPointItem) {
        self.id = item.id
        self.name = item.name
        self.proxy = item.proxy
        self.nodes = item.proxies
        self.type = item.type
    }
    
    init() {
        id = UUID()
        name = "New EndPoint"
        proxy = "Direct"
        nodes = []
        type = "select"
    }

    var id: UUID
    @Published var name: String
    @Published var proxy: String
    @Published var type: String
    @Published var nodes: [String] = []
    @Published var showingProxies = false
    @Published var showingEndpoints = false
    @Published var showingBuildinNodes = false
    @Published var showingPopover = false
    @Published var showingPopoverButton = false
    @Published var disablePicker = false
    
    func toEndPointItem() -> EndPointItem {
        return EndPointItem(name: name, proxy: proxy, type: type, proxies: nodes)
    }
}

func toEndPointViewModel(items: [EndPointItem]) -> [EndPointViewModel] {
    var viewModels: [EndPointViewModel] = []
    for item in items {
        viewModels.append(EndPointViewModel(item))
    }
    return viewModels
}

class EndPointListViewModel: ObservableObject {
    var cancellable: AnyCancellable?
    
    @Published var items: [EndPointViewModel]
    
    static var shared = EndPointListViewModel()
    
    
    func loadConfig(config: ClashConfig) {
        items.removeAll()
        for endPointConfig in config.proxyGroups {
            var proxiesSet: [String] = []
            for proxyName in endPointConfig.proxies {
                if !proxiesSet.contains(proxyName) {
                    proxiesSet.append(proxyName)
                }
            }
            let item = EndPointItem(name: endPointConfig.name, proxy: (endPointConfig.proxies.count > 0 ? endPointConfig.proxies.first! : ""), proxies: proxiesSet)
            items.append(EndPointViewModel(item))
        }
    }
    
    func fetchAllEndPointsStatus() {
        let url = URL(string: "http://127.0.0.1:6170/proxies")!
        NSLog("fetching endpoints status from \(url.path)")
        cancellable = URLSession.shared
            .dataTaskPublisher(for: url)
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                    httpResponse.statusCode == 200 else {
                        throw URLError(.badServerResponse)
                    }
                return element.data
                }
            .decode(type: ProxiesStatus.self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { NSLog("received completion \($0).") },
                  receiveValue: { proxiesStatus  in
                    for proxyStatusPair in proxiesStatus.proxies {
                        let proxyStatus = proxyStatusPair.value
                        if proxyStatus.type == "Selector" {
                            let i = self.items.firstIndex { endpointViewModel in
                                proxyStatus.name == endpointViewModel.name
                            }
                            if i != nil && proxyStatus.now != nil {
                                self.items[i!].proxy = proxyStatus.now!
                            }
                        }
                    }
                  })

    }
    
    func removeNodes(byName: Set<String>) {
        for item in items {
            item.nodes.removeAll { node in
                byName.contains(node)
            }
        }
    }
    
    func renameNodes(oldName: String, newName: String) {
        for item in items {
            item.nodes = item.nodes.map { nodeStr in
                nodeStr == oldName ? newName : nodeStr
            }
        }
    }
    
    func isUsing(proxyName: String) -> Bool {
        for endpointViewItem in self.items {
            if endpointViewItem.proxy == proxyName {
                return true
            }
        }
        return false
    }
    
    private init() {
        self.items = []
    }
}


