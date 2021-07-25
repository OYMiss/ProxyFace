//
//  ProxyDetailView.swift
//  ProxyFace (macOS)
//
//  Created by oymiss on 29/6/2021.
//

import SwiftUI

struct ProxyDetailView: View {
    @State var text: String = ""
    @ObservedObject var item: ProxyViewModel
    var alignment: Alignment = .trailing

    @State var method = ""
    @State var skipCertVerify: Bool = true

    let textWidth: CGFloat = 64
    
    init(item: ProxyViewModel, alignment: Alignment = .trailing) {
        self.item = item
        self.alignment = alignment
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                TextField("", text: $item.name)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.title2)
                    .disabled(EndPointListViewModel.shared.isUsing(proxyName: item.name))
            }
            HStack {
                Text("Type")
                    .frame(width: textWidth, alignment: alignment)
                    .foregroundColor(.secondary)
                
                Picker("", selection: $item.type) {
                    Text("shadowsocks").tag("shadowsocks").foregroundColor(.secondary)
                    Text("trojan").tag("trojan").foregroundColor(.secondary)
                    Text("socks5").tag("socks5").foregroundColor(.secondary)
                }
                .padding(.leading, -8)
                .frame(width: 112)
            }
            

            HStack {
                Text("Server")
                    .frame(width: textWidth, alignment: alignment)
                    .foregroundColor(.secondary)
                TextField("", text: $item.ip).textFieldStyle(PlainTextFieldStyle())
            }
            
            HStack {
                Text("Port")
                    .frame(width: textWidth, alignment: alignment)
                    .foregroundColor(.secondary)
                TextField("", text: $item.port).textFieldStyle(PlainTextFieldStyle())
                    .onChange(of: item.port, perform: { value in
                             //do any validation or alteration here
                        guard item.port == "" || Int(item.port) != nil else {
                            item.port = item.port.filter({ c in
                                c.isNumber
                            })
                            return
                        }
                        })
            }
            HStack {
                Text("Method")
                    .frame(width: textWidth, alignment: alignment)
                    .foregroundColor(.secondary)
                TextField("", text: $method).textFieldStyle(PlainTextFieldStyle())
            }.existWhen(item.type == "shadowsocks")
            
            HStack {
                Text("Password")
                    .frame(width: textWidth, alignment: alignment)
                    .foregroundColor(.secondary)
                TextField("", text: $item.password).textFieldStyle(PlainTextFieldStyle())
            }
            
            HStack {
                Text("SkipVerify")
                    .foregroundColor(.secondary)
                    .frame(width: textWidth, alignment: alignment)
                Toggle(isOn: $skipCertVerify, label: {
                    
                })
            }.existWhen(item.type == "trojan")
        }
        .onAppear() {
            if item.type == "shadowsocks" {
                if item.extra["cipher"] != nil {
                    method = item.extra["cipher"] as! String
                }
            }
            if item.type == "trojan" {
                skipCertVerify = item.extra["skipCertVerify"] as! Bool
            }
        }
        .onDisappear() {
            if item.type == "shadowsocks" {
                NSLog("set proxy extra value: method = \(method)")
                item.extra["cipher"] = method
            }
            if item.type == "trojan" {
                NSLog("set proxy extra value: skipCertVerify = \(skipCertVerify)")
                item.extra["skipCertVerify"] = skipCertVerify
            }
        }
    }
}

struct ProxyDetailContentView_Previews: PreviewProvider {

    static var previews: some View {
        let proxyItem = ProxyViewModel(ProxyItem(name: "BeiJing 01", type: "trojan", server: "192.12.32.12", status: "12ms"))
        ProxyDetailView(item: proxyItem)
    }
}
