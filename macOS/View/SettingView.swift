//
//  SettingView.swift
//  ProxyFace (macOS)
//
//  Created by oymiss on 5/7/2021.
//

import SwiftUI

struct SettingView: View {
    var body: some View {
        List {
            Button(action: {
                overwriteClashConfig()
            }, label: {
                Text("Save and Restart")
            })
            
            Button(action: {
                StopClash()
                StartClash()
            }, label: {
                Text("Discard and Restart")
            })
            
            Button(action: {
                overwriteClashConfig(restart: false)
            }, label: {
                Text("Save")
            })
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
