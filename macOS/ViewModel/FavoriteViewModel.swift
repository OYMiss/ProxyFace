//
//  FavoriteViewModel.swift
//  ProxyFace (macOS)
//
//  Created by oymiss on 2/7/2021.
//

import Foundation

class FavoriteViewModel: Identifiable, Hashable, ObservableObject {
    internal init(name: String, type: String) {
        self.name = name
        self.type = type
    }
    
    static func == (lhs: FavoriteViewModel, rhs: FavoriteViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        return hasher.combine(ObjectIdentifier(self))
    }
    
    init(endPointitem: EndPointViewModel) {
        self.name = endPointitem.name
        self.type = "endpoint"
    }
    
    init(ruleViewModel: RuleViewModel) {
        self.name = ruleViewModel.name
        self.type = "rule"
    }
    
    var id = UUID()
    @Published var name: String
    @Published var type: String
}

class FavoriteListViewModel: ObservableObject {

    @Published var endpointViewItems: Set<EndPointViewModel>
    @Published var ruleViewItems: Set<RuleViewModel>
    static let shared = FavoriteListViewModel()
    
    private init() {
//        let endPointListViewModel = EndPointListViewModel.shared
//        let ruleListViewModel = RuleListViewModel.shared

//        endpointViewItems = [endPointListViewModel.items[0], endPointListViewModel.items[1]]
//        ruleViewItems = [ruleListViewModel.items[1], ruleListViewModel.items[3]]
        endpointViewItems = []
        ruleViewItems = []
    }
    
    func loadConfig(config: UserConfig) {
        if config.favoriteEndpoints != nil {
            for endpointViewModel in EndPointListViewModel.shared.items {
                let isMark = config.favoriteEndpoints?.contains(endpointViewModel.name)
                if isMark != nil && isMark! {
                    self.endpointViewItems.insert(endpointViewModel)
                }
            }
        }
    }
    
}
