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
                StopClash()
                StartClash()
            }, label: {
                Text("Restart Clash Core")
            })
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
