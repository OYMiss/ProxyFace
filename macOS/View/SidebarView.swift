//
//  SidebarView.swift
//  ProxyFace (macOS)
//
//  Created by oymiss on 27/6/2021.
//

import SwiftUI

struct SidebarView: View {
    @State var selection: Int?

    var body: some View {
        NavigationView {
            List {
                //Caption
                Text("Services")
                //Navigation links
                //Replace "ContentView" with your destination
                Group{
                    NavigationLink(destination: HomeView(),tag: 0, selection: self.$selection) {
                        Label("Home", systemImage: "star")
                    }
                    NavigationLink(destination: ProxiesView()) {
                        Label("Proxies", systemImage: "square.stack.3d.up")
                    }
                    
                    NavigationLink(destination: EndPointsView()) {
                        Label("EndPoints", systemImage: "bolt")
                    }
                    
                    NavigationLink(destination: RulesView()) {
                        Label("Rules", systemImage: "list.bullet")
                    }

                }.onAppear {
                    self.selection = 0
                }
                //Add some space :)
//                Spacer()
//                Text("More")
//                NavigationLink(destination: Text("Hello")) {
//                    Label("Shortcut", systemImage: "option")
//                }
//                NavigationLink(destination: Text("Hello")) {
//                    Label("Customize", systemImage: "slider.horizontal.3")
//                }
                //Add some space again!
                Spacer()
                //Divider also looks great!
                Divider()
                NavigationLink(destination: SettingView()) {
                    Label("Settings", systemImage: "gear")
                }
            }
            .listStyle(SidebarListStyle())
            .navigationTitle("Explore")
            //Set Sidebar Width (and height)
            .frame(minWidth: 150, idealWidth: 250, maxWidth: 300)
            .toolbar{
                //Toggle Sidebar Button
                ToolbarItem(placement: .navigation){
                    Button(action: toggleSidebar, label: {
                        Image(systemName: "sidebar.left")
                    })
                }
            }
            //Default View on Mac
//            Text("Hello")
        }.frame(width: 640, height: 380)
    }
}

// Toggle Sidebar Function
func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView()
    }
}
