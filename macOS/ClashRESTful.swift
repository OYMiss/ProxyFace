//
//  ClashRESTful.swift
//  ProxyFace (macOS)
//
//  Created by oymiss on 4/7/2021.
//

import Foundation
import Combine

enum APIError: Error, LocalizedError {
    case unknown, apiError(reason: String)

    var errorDescription: String? {
        switch self {
        case .unknown:
            return "Unknown error"
        case .apiError(let reason):
            return reason
        }
    }
}

func fetch(request: URLRequest) -> AnyPublisher<Data, APIError> {
    return URLSession.DataTaskPublisher(request: request, session: .shared)
        .tryMap { data, response in
            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                throw APIError.unknown
            }
            return data
        }
        .mapError { error in
            if let error = error as? APIError {
                return error
            } else {
                return APIError.apiError(reason: error.localizedDescription)
            }
        }
        .eraseToAnyPublisher()
}


func changeEndPointTo(endPointName: String, proxyName: String) {
    let url = URL(string: "http://127.0.0.1:6170/proxies/\(endPointName)")!
    var request = URLRequest(url: url)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "PUT"
    request.httpBody = "{\"name\": \"\(proxyName)\"}".data(using: .utf8)
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data,
            let response = response as? HTTPURLResponse,
            error == nil else {                                              // check for fundamental networking error
            print("error", error ?? "Unknown error")
            return
        }

        guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
            print("statusCode should be 2xx, but is \(response.statusCode)")
            print("response = \(response)")
            return
        }
        
        let responseString = String(data: data, encoding: .utf8)
        print("responseString = \(responseString!)")
    }

    task.resume()

}

struct ProxyStatus: Codable {
    let all: [String]?
    let history: [String]?
    let name: String
    let now: String?
    let type: String
}

struct ProxiesStatus: Codable {
    let proxies: [String: ProxyStatus]
}


func getEndPointProxyRequest(endPointName: String) -> URLRequest {
    let url = URL(string: "http://127.0.0.1:6170/proxies/\(endPointName)")!
    var request = URLRequest(url: url)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "GET"
    return request
}
