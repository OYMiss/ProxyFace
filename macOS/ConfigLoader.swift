//
//  ConfigLoader.swift
//  ProxyFace (macOS)
//
//  Created by oymiss on 2/7/2021.
//

import Foundation
import Yams

struct UserConfig: Codable {
    var favoriteEndpoints: [String]?
}

struct ProxyConfig: Codable {
    var name: String
    var type: String
    var server: String
    var port: Int
    var password: String?
    var cipher: String?
    var udp: Bool?
    var alpn: [String]?
    var skipCertVerify: Bool?
    enum CodingKeys: String, CodingKey {
        case name
        case type
        case server
        case port
        case password
        case cipher
        case udp
        case alpn
        case skipCertVerify = "skip-cert-verify"
    }
}

struct EndPointConfig: Codable {
    var name: String
    var type: String
    var proxies: [String]
    var use: [String]?
}

struct RuleSetConfig: Codable {
    var type: String
    var behavior: String
    var url: String
    var path: String
    var interval: Int?
}

struct ProxySetConfig: Codable {
    var type: String
    var path: String
}

struct ClashConfig: Codable {
    var port: Int
    var socksPort: Int
    var mixedPort: Int
    var allowLan: Bool
    var mode: String
    var logLevel: String
    var externalController: String
    var proxies: [ProxyConfig]
    var proxyProviders: [String: ProxySetConfig]?
    var proxyGroups: [EndPointConfig]
    var rules: [String]
    var ruleProviders: [String: RuleSetConfig]
    enum CodingKeys: String, CodingKey {
        case port
        case socksPort = "socks-port"
        case mixedPort = "mixed-port"
        case allowLan = "allow-lan"
        case mode
        case logLevel = "log-level"
        case externalController = "external-controller"
        case proxies
        case proxyProviders = "proxy-providers"
        case proxyGroups = "proxy-groups"
        case rules
        case ruleProviders = "rule-providers"
    }
}

struct ConfigManager {
    static var config = ConfigManager()
    
    var clashConfigStr: String? = nil
    var clashConfig: ClashConfig? = nil
    var userConfig: UserConfig? = nil
    
    let home = FileManager.default.homeDirectoryForCurrentUser
    let clashFilePath: String
    let clashNewFilePath: String
    let userConfigFilePath: String
    let clashFileUrl: URL
    let clashNewFileUrl: URL
    let clashLaunchAgentUrl: URL
    let userConfigUrl: URL
    
    private init() {
        clashNewFilePath = "/Library/Application Support/io.github.oymiss.ProxyFace/clash/config_bak.yaml"
        clashFilePath = "/Library/Application Support/io.github.oymiss.ProxyFace/clash/config.yaml"
        userConfigFilePath = "/Library/Application Support/io.github.oymiss.ProxyFace/clash/user_config.yaml"

        clashNewFileUrl = home.appendingPathComponent(clashNewFilePath)
        clashFileUrl = home.appendingPathComponent(clashFilePath)
        clashLaunchAgentUrl = home.appendingPathComponent("/Library/LaunchAgents/io.github.oymiss.ProxyFace.clash.plist")
        userConfigUrl = home.appendingPathComponent(userConfigFilePath)
    }
}


extension String {
    func utf8DecodedString()-> String {
        let data = self.data(using: .utf8)
        let message = String(data: data!, encoding: .nonLossyASCII) ?? ""
        return message
    }
    
    func utf8EncodedString()-> String {
        let messageData = self.data(using: .nonLossyASCII)
        let text = String(data: messageData!, encoding: .utf8) ?? ""
        return text
    }
}

func loadClashConfig() {
    do {
//        let configManager = ConfigManager.config
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: ConfigManager.config.clashLaunchAgentUrl.path) {
            ConfigClash()
        }
        
        if !fileManager.fileExists(atPath: ConfigManager.config.clashFileUrl.path) {
            ConfigClash()
        }

        print("config exist: \(fileManager.fileExists(atPath: ConfigManager.config.clashFileUrl.path)), \(ConfigManager.config.clashFileUrl.path)")
        if fileManager.fileExists(atPath: ConfigManager.config.clashFileUrl.path) {
            let data = fileManager.contents(atPath: ConfigManager.config.clashFileUrl.path)
            if data != nil {
                // Read
                ConfigManager.config.clashConfigStr = String(data: data!, encoding: .utf8)
                
                // Decode
                let decoder = YAMLDecoder()
                let clashConfig = try decoder.decode(ClashConfig.self, from: ConfigManager.config.clashConfigStr!)
                ConfigManager.config.clashConfig = clashConfig
                
                EndPointListViewModel.shared.loadConfig(config: clashConfig)
                ProxyListViewModel.shared.loadConfig(config: clashConfig)
                RuleListViewModel.shared.loadConfig(config: clashConfig)
                EnableSystemProxy(httpPort: String(clashConfig.port), socksPort: String(clashConfig.socksPort))
            }
        }
    } catch {
        print("\(error)")
    }
}

func loadUserConfig() {
    do {
        let fileManager = FileManager.default

        print("user config exist: \(fileManager.fileExists(atPath: ConfigManager.config.userConfigUrl.path)), \(ConfigManager.config.userConfigUrl.path)")
        if fileManager.fileExists(atPath: ConfigManager.config.userConfigUrl.path) {
            let data = fileManager.contents(atPath: ConfigManager.config.userConfigUrl.path)
            if data != nil {
                // Read
                let str = String(data: data!, encoding: .utf8)
                
                // Decode
                let decoder = YAMLDecoder()
                let userConfig = try decoder.decode(UserConfig.self, from: str!)
                ConfigManager.config.userConfig = userConfig
                FavoriteListViewModel.shared.loadConfig(config: userConfig)
            }
        }
    } catch {
        print("\(error)")
    }
}

func saveUserConfig() {
    let fileManager = FileManager.default

    do {
        try fileManager.removeItem(at: ConfigManager.config.userConfigUrl)
    } catch {
        print("error at remove \(error)")
    }
    
    do {
        if FavoriteListViewModel.shared.endpointViewItems.count > 0 {
            var userConfig = UserConfig()
            userConfig.favoriteEndpoints = []
            for item in FavoriteListViewModel.shared.endpointViewItems {
                userConfig.favoriteEndpoints?.append(item.name)
            }
            // Encode
            let encoder = YAMLEncoder()
            let encodedYAML = try encoder.encode(userConfig)
            let encodedCN = encodedYAML.utf8DecodedString()
            let newData = encodedCN.data(using: .utf8)
            fileManager.createFile(atPath: ConfigManager.config.userConfigUrl.path, contents: newData)
        }
    } catch {
        print("error at create \(error)")
    }
}

let ShadowsocksExtraSet: Set<String> = ["cipher", "udp"]
let TrojanExtraSet: Set<String> = ["skipCertVerify", "alpn", "udp"]

func saveProxyConfig() {
    var newItems:[ProxyConfig] = []
    for proxyViewItem in ProxyListViewModel.shared.items {
        let proxyItem = proxyViewItem.toProxyItem()
        
        if proxyItem.type == "shadowsocks" {
            proxyItem.extra = proxyItem.extra.filter { element in
                ShadowsocksExtraSet.contains(element.key)
            }
        }
        
        if proxyItem.type == "trojan" {
            proxyItem.extra = proxyItem.extra.filter { element in
                TrojanExtraSet.contains(element.key)
            }
        }
                
        let proxyConfig = ProxyConfig(name: proxyItem.name,
                                      type: proxyItem.type == "shadowsocks" ? "ss" : proxyItem.type,
                                      server: proxyItem.server,
                                      port: Int(proxyItem.port) ?? 443,
                                      password: proxyItem.password,
                                      cipher: proxyItem.extra["cipher"] as? String,
                                      udp: proxyItem.extra["udp"] as? Bool,
                                      alpn: proxyItem.extra["alpn"] as? [String],
                                      skipCertVerify: proxyItem.extra["skipCertVerify"] as? Bool)
        newItems.append(proxyConfig)
    }
    ConfigManager.config.clashConfig?.proxies = newItems
}

func saveEndPointConfig() {
    var newItems:[EndPointConfig] = []
    EndPointListViewModel.shared.cleanDeleteProxy()
    for endPointViewItem in EndPointListViewModel.shared.items {
        let endPointItem = endPointViewItem.toEndPointItem()
        let endPointConfig = EndPointConfig(name: endPointItem.name, type: endPointItem.type, proxies: Array(endPointItem.proxies), use: nil)
        newItems.append(endPointConfig)
    }
    ConfigManager.config.clashConfig?.proxyGroups = newItems
}

func saveRuleConfig() {
    var newItems:[String] = []
    for ruleViewItem in RuleListViewModel.shared.items {
        let ruleItem = ruleViewItem.toRuleItem()
        var rule: String = ""
        if ruleItem.type == "FINAL" {
            rule = "\(ruleItem.name),\(ruleItem.endpoint)"
        } else {
            rule = "\(ruleItem.type),\(ruleItem.name),\(ruleItem.endpoint)"
        }
        newItems.append(rule)
    }
    ConfigManager.config.clashConfig?.rules = newItems
}

func overwriteClashConfig(restart: Bool = true) {
    let fileManager = FileManager.default
    
    saveClashConfigToNewConfig()
    if restart {
        StopClash()
    }
    do {
        try fileManager.removeItem(at: ConfigManager.config.clashFileUrl)
    } catch {
        print("error at remove \(error)")
    }
    
    do {
        try fileManager.copyItem(at: ConfigManager.config.clashNewFileUrl, to: ConfigManager.config.clashFileUrl)
    } catch {
        print("error at copy \(error)")
    }
    
    if restart {
        StartClash()
    }
 
}

func saveClashConfigToNewConfig() {
    let fileManager = FileManager.default

    do {
//        EndPointListViewModel.shared.loadConfig(config: clashConfig)
//        ProxyListViewModel.shared.loadConfig(config: clashConfig)
//        RuleListViewModel.shared.loadConfig(config: clashConfig)
        saveProxyConfig()
        saveEndPointConfig()
        saveRuleConfig()
        let clashConfig = ConfigManager.config.clashConfig
        // Encode
        let encoder = YAMLEncoder()
        let encodedYAML = try encoder.encode(clashConfig)
        let encodedCN = encodedYAML.utf8DecodedString()
        let newData = encodedCN.data(using: .utf8)
        fileManager.createFile(atPath: ConfigManager.config.clashNewFileUrl.path, contents: newData)
    } catch {
        print("\(error)")
    }

}

func ConfigClash() {
    print("installing clash")
    let bundle = Bundle.main
    let bashPath = bundle.path(forResource: "install.sh", ofType: nil)
    let str = bundle.resourceURL?.path
    let task = Process.launchedProcess(launchPath: bashPath!, arguments: [str!])
    task.waitUntilExit()
    if task.terminationStatus == 0 {
        NSLog("Install clash succeeded.")
    } else {
        NSLog("Install clash failed.")
    }
}

func StartClash() {
    print("starting clash")
    let bundle = Bundle.main
    let bashPath = bundle.path(forResource: "start_clash.sh", ofType: nil)
    let task = Process.launchedProcess(launchPath: bashPath!, arguments: [""])
    task.waitUntilExit()
    if task.terminationStatus == 0 {
        NSLog("Start clash succeeded.")
    } else {
        NSLog("Start clash failed.")
    }
}

func StopClash() {
    print("stoping clash")
    let bundle = Bundle.main
    let bashPath = bundle.path(forResource: "stop_clash.sh", ofType: nil)
    let task = Process.launchedProcess(launchPath: bashPath!, arguments: [""])
    task.waitUntilExit()
    if task.terminationStatus == 0 {
        NSLog("Stop clash succeeded.")
    } else {
        NSLog("Stop clash failed.")
    }
}

func EnableSystemProxy(httpPort: String, socksPort: String) {
    print("enable system proxy")
    let bundle = Bundle.main
    let bashPath = bundle.path(forResource: "configure_proxy.sh", ofType: nil)
    let task = Process.launchedProcess(launchPath: bashPath!, arguments: ["on", httpPort, socksPort])
    task.waitUntilExit()
    if task.terminationStatus == 0 {
        NSLog("enable system proxy succeeded.")
    } else {
        NSLog("enable system proxy failed.")
    }
}

func DisableSystemProxy() {
    print("disable system proxy")
    let bundle = Bundle.main
    let bashPath = bundle.path(forResource: "configure_proxy.sh", ofType: nil)
    let task = Process.launchedProcess(launchPath: bashPath!, arguments: ["off"])
    task.waitUntilExit()
    if task.terminationStatus == 0 {
        NSLog("disable system proxy succeeded.")
    } else {
        NSLog("disable system proxy failed.")
    }
}
