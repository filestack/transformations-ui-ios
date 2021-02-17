//
//  Config.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 31/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

/// Configuration object for `TransformationsUI`.
open class Config: NSObject {
    /// An object conforming to `EditorModules` that contains the modules and configuration for each
    /// available module.
    public let modules: EditorModules

    override private init() {
        self.modules = Modules()
    }

    /// Designated initializer.
    ///
    /// - Parameter modules: An object conforming to `EditorModules`.
    public init(modules: EditorModules = Modules()) {
        self.modules = modules
    }
}
