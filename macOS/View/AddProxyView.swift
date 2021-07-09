//
//  AddProxyView.swift
//  ProxyFace (macOS)
//
//  Created by oymiss on 30/6/2021.
//

import SwiftUI

struct AddProxyView: View {
    @StateObject var newProxyViewModel = ProxyViewModel()
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var listViewModel: ProxyListViewModel
    @State var save = false
    var body: some View {
        VStack(alignment: .trailing) {
            HStack {
                VStack {
                    GroupBox(
                        label: Label("Proxy Setting", systemImage: "gear")
                            .foregroundColor(.gray)
                    ) {
                        ProxyDetailView(item: newProxyViewModel, alignment: .leading)
                            .padding(.leading, 8)
                            .padding(.bottom, 4)
                            .padding(.top, 4)
                            .frame(width: 320)
                            .onDisappear() {
                                if save {
                                    listViewModel.items.append(newProxyViewModel)
                                    NodeListViewModel.shared.add(proxyViewModel: newProxyViewModel)
                                    saveClashConfig()
                                }
                            }
                    }
                }
            }
            HStack {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Button("OK") {
                    save = true
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }.padding(.top, 8)
        }.padding()
        
    }
    
}

struct AddProxyView_Previews: PreviewProvider {
    static var previews: some View {
        AddProxyView().environmentObject(ProxyListViewModel.shared)
    }
}
