//
//  HomeView.swift
//  ProxyFace (macOS)
//
//  Created by oymiss on 27/6/2021.
//

import SwiftUI

struct HomeView: View {
    private func connect() {
        print("connect")
    }
    
    @StateObject var listViewModel: FavoriteListViewModel = FavoriteListViewModel.shared

    // Test!!
    @State private var selectedProxy = 2
    @State var selectedItems: Set<EndPointViewModel> = []
    
    var body: some View {
        List(selection: $selectedItems) {
            HStack {
                Text("Connect").foregroundColor(.blue)
            }
            
            Divider()

            Label("Favorite", systemImage: "heart").font(.title3)

            ForEach(Array(listViewModel.endpointViewItems), id: \.self) { item in
                EndPointRowView(item: item, isSelected: selectedItems.contains(item))
            }
//            Label("Favorite", systemImage: "list.bullet").font(.title3)
//
//            ForEach(listViewModel.ruleViewItems, id: \.id) { item in
//                RuleRowView(item: item, isSelected: false)
//            }
            Divider()
            HStack {
                Label("Preview", systemImage: "waveform.path.ecg").font(.title3)
                Spacer()
                Image(systemName: "plus").font(.title3).foregroundColor(.blue)
            }

            HStack {
                Text("google.com")
                Spacer()
                Text("HongKong IPLC 05").foregroundColor(.secondary)
            }
            HStack {
                Text("apple.com")
                Spacer()
                Text("HongKong IPLC 05").foregroundColor(.secondary)
            }
            
        }
        
        .navigationTitle("Home")
        .toolbar {
            //Toggle Sidebar Button
            ToolbarItem {
                Button(action: {
                    for item in selectedItems {
                        listViewModel.endpointViewItems.remove(item)
                    }
                }, label: {
                    Image(systemName: "heart.slash")
                })
            }
        }
    }
}

struct HomeContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
