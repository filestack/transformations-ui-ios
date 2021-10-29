//
//  Config.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 31/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation
import Filestack

/// Configuration object for `TransformationsUI`.
open class Config: NSObject {
    /// An object conforming to `EditorModules` that contains the modules and configuration for each
    /// available module.
    public let modules: EditorModules

    /// Filestack Client.
    public let fsClient: Filestack.Client

    static func fontsURLs() -> [URL] {
        [
            "Montserrat-Regular",
            "Montserrat-SemiBold",
            "Montserrat-Bold"
        ]
        .map { Bundle.module.url(forResource: $0, withExtension: "ttf")! }
    }

    /// Designated initializer.
    ///
    /// - Parameter modules: An object conforming to `EditorModules`.
    public init(modules: EditorModules, fsClient: Filestack.Client) throws {
        self.modules = modules
        self.fsClient = fsClient

        super.init()

        try prefetch(using: fsClient.apiKey)

        for module in modules.all {
            if let module = module as? RequiresFSClient {
                module.fsClient = fsClient
            }
        }
    }
}
