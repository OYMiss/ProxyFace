//
//  HomeViewModel.swift
//  ProxyFace (macOS)
//
//  Created by 杨崇卓 on 8/7/2021.
//

import Foundation
import Combine

struct ClashStatus: Codable {
    var hello: String
}

class HomeViewModel: Identifiable, Hashable, ObservableObject {
    var cancellable: AnyCancellable?
    @Published var clashStatus = "Stopped"
    
    let id = UUID()
    static func == (lhs: HomeViewModel, rhs: HomeViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        return hasher.combine(ObjectIdentifier(self))
    }
    
    static var shared = HomeViewModel()
    
    private init() {
    }
    
    func fetchClashStatus() {
        let url = URL(string: "http://127.0.0.1:6170")!
        print("check clash status")
        cancellable = URLSession.shared
            .dataTaskPublisher(for: url)
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                    httpResponse.statusCode == 200 else {
                        print("clash is not running")
                        throw URLError(.badServerResponse)
                    }
                return element.data
                }
            .decode(type: ClashStatus.self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { print ("Received completion: \($0).") },
                  receiveValue: { clashStatusEntity  in
                    self.clashStatus = "Running"
                  })
    }
}
