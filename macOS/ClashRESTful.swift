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

struct ClashStatus: Codable {
    var hello: String
}
