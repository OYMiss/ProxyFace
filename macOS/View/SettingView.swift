//
//  SettingView.swift
//  ProxyFace (macOS)
//
//  Created by oymiss on 5/7/2021.
//

import SwiftUI

struct SettingView: View {
    @State var configPath = "~/Library/Application Support/io.github.oymiss.ProxyFace/clash"
    @State var logPath = "~/Library/Logs/clash.log"

    var body: some View {
        List {
            VStack(alignment: .leading, spacing: 2) {
                Text("Config Path").font(.footnote).foregroundColor(.secondary)
                TextField("", text: .constant(configPath))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Log Path").font(.footnote).foregroundColor(.secondary)
                TextField("", text: .constant(logPath))
            }
        }.toolbar {
            ToolbarItem {
                Button(action: {
                    StopClash()
                    loadClashConfig()
                    StartClash()
                }, label: {
                    Text("Restart")
                })
            }
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
