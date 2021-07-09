//
//  AddEndPointView.swift
//  ProxyFace (macOS)
//
//  Created by oymiss on 1/7/2021.
//

import SwiftUI

struct AddEndPointView: View {
    @StateObject var newEndPointViewModel = EndPointViewModel()
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var listViewModel: EndPointListViewModel
    
    var body: some View {
        VStack(alignment: .trailing) {
            HStack {
                VStack {
                    GroupBox(
                        label: Label("EndPoint Setting", systemImage: "gear")
                            .foregroundColor(.gray)
                    ) {
                        EndPointDetailView(item: newEndPointViewModel, nodeListViewModel: NodeListViewModel.shared, listWidth: 288)
                            .padding(.leading, 16)
//                            .padding(.trailing, 16)
                            .padding(.bottom, 8)
                            .padding(.top, 4)
                            .frame(width: 320, height: 140)
                    }
                }
            }
            HStack {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Button("OK") {
                    listViewModel.items.append(newEndPointViewModel)
                    NodeListViewModel.shared.add(endpointViewModel: newEndPointViewModel)
                    saveClashConfig()
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }.padding(.top, 8)
        }.padding()
    }
}

struct AddEndPointView_Previews: PreviewProvider {
    static var previews: some View {
        AddEndPointView()
    }
}
