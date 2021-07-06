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
                    }
//                    GroupBox(
//                        label: Label("Status", systemImage: "waveform.path.ecg")
//                            .foregroundColor(.gray)
//                    ) {
//                        VStack {
//                            HStack {
//                                Text("Latency").frame(width: 64, alignment: .trailing)
//                                .foregroundColor(.secondary)
//                                Text("50ms").foregroundColor(.green)
//                                Spacer()
//                                Button(action: {
//                                    print("test")
//                                }, label: {
//                                    Text("Test")
//                                })
//                            }
//                        }
//                        .frame(width: 320, alignment: .leading)
//                    }
                }

//                VStack {

//                    GroupBox(
//                        label: Label("Raw Text", systemImage: "text.alignleft")
//                            .foregroundColor(.gray)
//                    ) {
//                        TextEditor(text: .constant("name: 俄罗斯 AIA 01\ntype: shadowsocks\nserver: 162.14.19.131\nport: 758\npassword: huaweibest"))
//                    }
//                }.frame(minWidth: 100)

            }
            HStack {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
//                .buttonStyle(BorderedButtonStyle())
                .keyboardShortcut(.cancelAction)
                
                Button("OK") {
                    listViewModel.items.append(newProxyViewModel)
                    NodeListViewModel.shared.refresh()
                    saveClashConfigToNewConfig()
                    presentationMode.wrappedValue.dismiss()
                }
//                .buttonStyle(BorderedButtonStyle())
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
