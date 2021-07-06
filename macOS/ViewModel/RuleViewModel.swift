//
//  RuleViewModel.swift
//  ProxyFace (macOS)
//
//  Created by oymiss on 1/7/2021.
//

import Foundation

class RuleViewModel: Identifiable, Hashable, ObservableObject {
    static func == (lhs: RuleViewModel, rhs: RuleViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        return hasher.combine(ObjectIdentifier(self))
    }
    
    internal init(_ item: RuleItem) {
        self.id = item.id
        self.name = item.name
        self.type = item.type
        self.endpoint = item.endpoint
        self.extra = item.extra
    }
    
    init() {
        id = UUID()
        name = "example.com"
        type = "DOMAIN-SUFFIX"
    }

    var id: UUID
    @Published var name: String
    @Published var type: String
    @Published var endpoint: String = "DIRECT"
    @Published var extra: [String: String] = [:]
    @Published var showingPopover = false
    @Published var showingPopoverButton = false

    func toRuleItem() -> RuleItem {
        return RuleItem(name: name, type: type, endpoint: endpoint)
    }
    
}

func toRuleViewModel(items: [RuleItem]) -> [RuleViewModel] {
    var viewModels: [RuleViewModel] = []
    for item in items {
        viewModels.append(RuleViewModel(item))
    }
    return viewModels
}

class RuleListViewModel: ObservableObject {

    @Published var items: [RuleViewModel]
    static var shared = RuleListViewModel()
    
    func loadConfig(config: ClashConfig) {
        items.removeAll()

        for ruleStr in config.rules {
            let rule = ruleStr.split(separator: ",")
            if rule.count == 3 {
                let type = rule[0].trimmingCharacters(in: [" ", "\r", "\n", "\t"])
                let name = rule[1].trimmingCharacters(in: [" ", "\r", "\n", "\t"])
                let endpoint = rule[2].trimmingCharacters(in: [" ", "\r", "\n", "\t"])
                let item = RuleItem(name: name, type: type, endpoint: endpoint)
                items.append(RuleViewModel(item))
            } else if rule.count == 2 {
                let name = rule[0].trimmingCharacters(in: [" ", "\r", "\n", "\t"])
                let endpoint = rule[1].trimmingCharacters(in: [" ", "\r", "\n", "\t"])
                let item = RuleItem(name: name, type: "FINAL", endpoint: endpoint)
                items.append(RuleViewModel(item))
            }
        }
    }
    
    private init() {
        self.items = []
    }
}
