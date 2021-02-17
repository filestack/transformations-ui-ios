//
//  JSONRequester.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 20/08/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import Foundation

class JSONRequester {
    enum Error: Swift.Error {
        case custom(_ description: String)
    }

    func request<JSONResponse: Codable>(url: URL, parameters: [String: Any]) throws -> JSONResponse {
        let semaphore = DispatchSemaphore(value: 0)
        let session = URLSession(configuration: .ephemeral)
        var request = URLRequest(url: url)

        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])

        var data: Data?
        var error: Swift.Error?

        let task = session.dataTask(with: request) { (_data, _, _error) in
            data = _data
            error = _error
            semaphore.signal()
        }

        task.resume()
        semaphore.wait()

        if let error = error {
            throw error
        } else if let data = data, let response = try? JSONDecoder().decode(JSONResponse.self, from: data) {
            return response
        } else {
            throw Error.custom("Unable to obtain response.")
        }
    }
}

