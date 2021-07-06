//
//  RuleDetailView.swift
//  ProxyFace (macOS)
//
//  Created by oymiss on 1/7/2021.
//

import SwiftUI

func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}

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
//                    Text("RULE-SET").tag("RULE-SET").foregroundColor(.secondary)
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
//                TextField("", text: $item.endpoint)
            }
            
//            VStack {
//                HStack {
//                    Text("Behavior")
//                        .frame(width: 64, alignment: alignment)
//                        .foregroundColor(.secondary)
//                    TextField("", text: $item.extra["behavior"] ?? "").textFieldStyle(PlainTextFieldStyle())
//                }
//
//                HStack {
//                    Text("Set Type")
//                        .frame(width: 64, alignment: alignment)
//                        .foregroundColor(.secondary)
//                    TextField("", text: $item.extra["type"] ?? "").textFieldStyle(PlainTextFieldStyle())
//                }
//
//                HStack {
//                    Text("URL")
//                        .frame(width: 64, alignment: alignment)
//                        .foregroundColor(.secondary)
//                    TextField("", text: $item.extra["url"] ?? "").textFieldStyle(PlainTextFieldStyle())
//                }.existWhen(item.extra["type"] == "http")
//
//                HStack {
//                    Text("Path")
//                        .frame(width: 64, alignment: alignment)
//                        .foregroundColor(.secondary)
//                    TextField("", text: $item.extra["path"] ?? "").textFieldStyle(PlainTextFieldStyle())
//                }
//            }.existWhen(item.type == "RULE-SET")

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
