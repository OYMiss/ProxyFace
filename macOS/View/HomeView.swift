//
//  HomeView.swift
//  ProxyFace (macOS)
//
//  Created by oymiss on 27/6/2021.
//

import SwiftUI

struct HomeView: View {    
    @StateObject var listViewModel: FavoriteListViewModel = FavoriteListViewModel.shared
    @StateObject var homeViewModel: HomeViewModel = HomeViewModel.shared
    
    // Test!!
    @State private var selectedProxy = 2
    @State var selectedItems: Set<EndPointViewModel> = []
    
    private func delayFetchStatus() {
        homeViewModel.clashStatus = "Checking"
        // Delay of 0.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            homeViewModel.fetchClashStatus()
        }
    }
    
    var body: some View {
        List(selection: $selectedItems) {
            HStack {
                Text(homeViewModel.clashStatus)
                    .foregroundColor(homeViewModel.clashStatus == "Error" ? .red : .blue)
                    .alert(isPresented: $homeViewModel.showNotRunningAlert) {
                        Alert(title: Text("Clash is not running"),
                              message: Text("please check log and config."),
                              primaryButton: .default(Text("Retry"), action: {
                                StopClash()
                                StartClash()
                                sleep(1)
                                homeViewModel.fetchClashStatus()
                              }),
                              secondaryButton: .default(Text("OK")))
                    }
            }
            
            Divider()

            Label("Favorite", systemImage: "heart").font(.title3)

            ForEach(Array(listViewModel.endpointViewItems), id: \.self) { item in
                EndPointRowView(item: item, isSelected: selectedItems.contains(item))
            }
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
                        listViewModel.endpointViewItems.removeAll { viewItem in
                            viewItem == item
                        }
                    }
                    saveUserConfig()
                }, label: {
                    Image(systemName: "heart.slash")
                })
            }
        }.onAppear(perform: delayFetchStatus)
    }
}

struct HomeContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
