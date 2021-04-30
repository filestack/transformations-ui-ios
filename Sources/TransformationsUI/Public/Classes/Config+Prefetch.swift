//
//  Config+Prefetch.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 15/4/21.
//  Copyright © 2021 Filestack. All rights reserved.
//

import Foundation

struct PrefetchResponse: Codable {
    let blocked: Bool?
    let permissions: [String: Bool]?
}

extension Config {
    enum Error: Swift.Error {
        case prefetch(_ description: String)
    }
}

extension Config.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .prefetch(description):
            return description
        }
    }
}

extension Config {
    func prefetch(using apiKey: String) throws {
        let url = URL(string: "https://upload.filestackapi.com/prefetch")!
        let permission = "transforms_ui"
        let event = "transform_ui"

        let parameters: [String: Any] = [
            "apikey": apiKey,
            "permissions": [permission],
            "events": [event]
        ]

        if let response: PrefetchResponse = try JSONRequester().request(url: url, parameters: parameters) {
            guard response.blocked == false else {
                throw Error.prefetch("Application is blocked.")
            }

            guard response.permissions?[permission] == true else {
                throw Error.prefetch("Unable to obtain permission for `\(permission)`.")
            }
        }
    }
}
