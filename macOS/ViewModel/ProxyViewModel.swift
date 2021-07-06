//
//  ProxyViewModel.swift
//  ProxyFace (macOS)
//
//  Created by oymiss on 1/7/2021.
//

import Foundation


class ProxyViewModel : Identifiable, Hashable, ObservableObject {
    static func == (lhs: ProxyViewModel, rhs: ProxyViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        return hasher.combine(ObjectIdentifier(self))
    }
    
    let id = UUID()
    @Published var ip: String = ""
    @Published var name: String = ""
    @Published var type: String = ""
    @Published var status: String = ""
    @Published var password: String = "default password"
    @Published var port: String = "443"
    @Published var extra: [String: Any] = [:]

    @Published var isCreating: Bool
    @Published var showingPopover: Bool = false
    @Published var checkedFlag: Bool = false
    
    init(_ item: ProxyItem) {
        isCreating = false
        ip = item.server
        name = item.name
        type = item.type
        status = item.status
        password = item.password
        port = item.port
        extra = item.extra
    }
    
    func toProxyItem() -> ProxyItem {
        return ProxyItem(name: name, type: type, server: ip, port: port, password: password, extra: extra, status: status)
    }
    
    init() {
        name = "New Server"
        ip = "127.0.0.1"
        type = "shadowsocks"
        isCreating = true
    }
}

func toProxyViewModel(items: [ProxyItem]) -> [ProxyViewModel] {
    var viewModels: [ProxyViewModel] = []
    for item in items {
        viewModels.append(ProxyViewModel(item))
    }
    return viewModels
}

class ProxyListViewModel: ObservableObject {
    @Published var items: [ProxyViewModel]
    
    static var shared = ProxyListViewModel()
    var typeMap = [String: String]()
    
    func loadConfig(config: ClashConfig) {
        items.removeAll()
        typeMap["ss"] = "shadowsocks"
        typeMap["trojan"] = "trojan"
        typeMap["socks5"] = "socks5"
        
        for proxyConfig in config.proxies {
            var extra:[String: Any] = [:]
            if proxyConfig.cipher != nil {
                extra["cipher"] = proxyConfig.cipher!
            }
            if proxyConfig.skipCertVerify != nil {
                extra["skipCertVerify"] = proxyConfig.skipCertVerify!
            }
            if proxyConfig.udp != nil {
                extra["udp"] = proxyConfig.udp
            }
            
            if proxyConfig.alpn != nil {
                extra["alpn"] = proxyConfig.alpn
            }
            
            let item = ProxyItem(name: proxyConfig.name,
                                 type: typeMap[proxyConfig.type] ?? "",
                                 server: proxyConfig.server,
                                 port: String(proxyConfig.port),
                                 password: (proxyConfig.password == nil ? "" : proxyConfig.password!),
                                 extra: extra,
                                 status: "")
            items.append(ProxyViewModel(item))
        }
    }
        
    private init() {
        self.items = []
    }
}
