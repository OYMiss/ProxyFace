//
//  AddRuleView.swift
//  ProxyFace (macOS)
//
//  Created by oymiss on 1/7/2021.
//

import SwiftUI

struct AddRuleView: View {
    @StateObject var newRuleViewModel = RuleViewModel()
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var listViewModel: RuleListViewModel
    
    var body: some View {
        VStack(alignment: .trailing) {
            HStack {
                VStack {
                    GroupBox(
                        label: Label("Rule Setting", systemImage: "gear")
                            .foregroundColor(.gray)
                    ) {
                        RuleDetailView(item: newRuleViewModel, alignment: .leading)
                            .padding(.leading, 8)
                            .padding(.bottom, 4)
                            .padding(.top, 4)
                            .frame(width: 320)
                    }

                }
            }
            HStack {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Button("OK") {
                    listViewModel.items.insert(newRuleViewModel, at: 0)
                    saveClashConfig()
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }.padding(.top, 8)
        }.padding()
    }
}

struct AddRuleView_Previews: PreviewProvider {
    static var previews: some View {
        AddRuleView()
    }
}
