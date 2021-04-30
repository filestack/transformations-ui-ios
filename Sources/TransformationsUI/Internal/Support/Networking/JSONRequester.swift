//
//  JSONRequester.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 20/08/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import Foundation

class JSONRequester {
    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral

        configuration.httpAdditionalHeaders = ["User-Agent" : "transformations-ui-ios \(shortVersionString)"]

        return URLSession(configuration: configuration)
    }()

    func request<JSONResponse: Codable>(url: URL, parameters: [String: Any]) throws -> JSONResponse {
        var request = URLRequest(url: url)

        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])

        var data: Data?
        var error: Swift.Error?

        let semaphore = DispatchSemaphore(value: 0)

        let task = session.dataTask(with: request) { (_data, _, _error) in
            data = _data
            error = _error
            semaphore.signal()
        }

        task.resume()
        semaphore.wait()

        if let error = error {
            throw error
        } else if let data = data {
            return try JSONDecoder().decode(JSONResponse.self, from: data)
        } else {
            throw Error.custom("Unable to obtain response.")
        }
    }
}

extension JSONRequester {
    enum Error: Swift.Error {
        case custom(_ description: String)
    }
}

private extension JSONRequester {
    var shortVersionString: String {
        guard let url = Bundle.module.url(forResource: "VERSION", withExtension: nil),
              let version = try? String(contentsOf: url) else { return "0.0.0" }

        return version
            .replacingOccurrences(of: "\r", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
