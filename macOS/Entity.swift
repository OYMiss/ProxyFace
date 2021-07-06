//
//  Entity.swift
//  ProxyFace (macOS)
//
//  Created by oymiss on 1/7/2021.
//

import Foundation

struct RuleItem: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var type: String
    var endpoint: String = "Direct"

    // behavior, url, path, interval
    var extra: [String: String] = [:]
}

class ProxyItem: Identifiable, Hashable {
    
    internal init(name: String, type: String, server: String, port: String = "532", password: String = "huaweibest", extra: [String : Any] = [:], status: String) {
        self.name = name
        self.type = type
        self.server = server
        self.port = port
        self.password = password
        self.extra = extra
        self.status = status
    }
    
    static func == (lhs: ProxyItem, rhs: ProxyItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        return hasher.combine(ObjectIdentifier(self))
    }
    
    let id = UUID()
    var name: String
    var type: String
    var server: String
    var port: String = "532"
    var password: String = "huaweibest"
    
//    var cipher: String = "aes-128-gcm"
    var extra: [String: Any] = [:]

    var status: String
}

struct EndPointItem: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var proxy: String
    var type: String = "select"
    var proxies: [String]
}

var testRuleItems = [
    RuleItem(name: "cordcloud", type: "DOMAIN-KEYWORD", endpoint: "Proxy"),
    RuleItem(name: "Apple", type: "RULE-SET", endpoint: "Direct", extra: [
        "type": "http",
        "url": "https://cdn.jsdelivr.net/gh/lhie1/Rules@master/Clash/Provider/Apple.yaml",
        "path": "./Rules/Apple",
        "behavior": "classical"
    ]),
    RuleItem(name: "PROXY", type: "RULE-SET", endpoint: "Proxy", extra: [
        "type": "http",
        "url": "https://cdn.jsdelivr.net/gh/lhie1/Rules@master/Clash/Provider/Proxy.yaml",
        "path": "./Rules/Proxy",
        "behavior": "classical"
    ]),
    RuleItem(name: "FINAL", type: "FINAL", endpoint: "Direct"),
]

var testProxyItems = [
    ProxyItem(name: "121.12.33.21", type: "HongKong IPLC 01", server: "shadowsocks", status: "17ms"),
    ProxyItem(name: "91.12.33.21", type: "HongKong IPLC 02", server: "shadowsocks", status: "77ms"),
    ProxyItem(name: "33.12.33.21", type: "Japan IPLC", server: "trojan", status: "37ms"),
]

var testEndPointItems = [
    EndPointItem(name: "Proxy", proxy: "HongKong IPLC 01", proxies: ["HongKong IPLC 01", "HongKong IPLC 02", "Direct", "Reject"]),
    EndPointItem(name: "Apple", proxy: "Proxy", proxies: ["Proxy", "HongKong IPLC 02", "Direct"]),
    EndPointItem(name: "JP-Proxy", proxy: "Japan IPLC", proxies: ["Japan IPLC", "Proxy"]),
]
