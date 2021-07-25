//
//  HomeViewModel.swift
//  ProxyFace (macOS)
//
//  Created by 杨崇卓 on 8/7/2021.
//

import Foundation
import Combine

class HomeViewModel: Identifiable, Hashable, ObservableObject {
    var cancellable: AnyCancellable?
    @Published var clashStatus = "Checking"
    @Published var showNotRunningAlert = false
    
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
        NSLog("check clash status from \(url.path)")
        cancellable = URLSession.shared
            .dataTaskPublisher(for: url)
            .delay(for: .seconds(2), scheduler: RunLoop.main, options: .none)
            .retry(3)
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                    httpResponse.statusCode == 200 else {
                        NSLog("clash is not running")
                        throw URLError(.badServerResponse)
                    }
                return element.data
                }
            .decode(type: ClashStatus.self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { complete in
                switch complete {
                case .finished:
                    self.clashStatus = "Running"
                    NSLog("clash is running")
                    self.showNotRunningAlert = false
                    break
                case .failure(_):
                    self.showNotRunningAlert = true
                    self.clashStatus = "Error"
                    NSLog("clash is not running, check your config!")
                    break
                }
            },
            receiveValue: { clashStatusEntity  in
                self.clashStatus = "Running"
                EndPointListViewModel.shared.fetchAllEndPointsStatus()
            })
    }
}
