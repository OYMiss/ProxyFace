//
//  RuleDetailView.swift
//  ProxyFace (macOS)
//
//  Created by oymiss on 1/7/2021.
//

import SwiftUI

struct RuleDetailView: View {
    @ObservedObject var item: RuleViewModel
    var alignment: Alignment = .trailing
    
    var nodeListViewModel: NodeListViewModel = NodeListViewModel.shared

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Rule Type")
                    .frame(width: 64, alignment: alignment)
                    .foregroundColor(.secondary)
                
                Picker("", selection: $item.type) {
                    Text("DOMAIN-SUFFIX").tag("DOMAIN-SUFFIX").foregroundColor(.secondary)
                    Text("DOMAIN-KEYWORD").tag("DOMAIN-KEYWORD").foregroundColor(.secondary)
                    Text("PROCESS-NAME").tag("PROCESS-NAME").foregroundColor(.secondary)
                    Text("IP-CIDR").tag("IP-CIDR").foregroundColor(.secondary)
                }
                .padding(.leading, -8)
            }
            
            HStack {
                Text("Value")
                    .frame(width: 64, alignment: alignment)
                    .foregroundColor(.secondary)
                
                TextField("", text: $item.name)
            }
            
            
            HStack {
                Text("Endpoint")
                    .frame(width: 64, alignment: alignment)
                    .foregroundColor(.secondary)
                Picker("", selection: $item.endpoint) {
                    ForEach(nodeListViewModel.endpointViewItems) { item in
                        Text(item.name).tag(item.name)
                    }
                    ForEach(nodeListViewModel.buildinViewItems) { item in
                        Text(item.name).tag(item.name)
                    }
                }.padding(.leading, -8)
            }
        }
    }
}

struct RuleDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let item = RuleViewModel(RuleItem(name: "Apple", type: "RULE-SET", endpoint: "Proxy", extra: [
            "type": "http",
            "url": "https://cdn.jsdelivr.net/gh/lhie1/Rules@master/Clash/Provider/Apple.yaml",
            "path": "./Rules/Apple",
            "behavior": "classical"
        ]))
        RuleDetailView(item: item)
    }
}
