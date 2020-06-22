//
//  Config.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 31/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

open class Config: NSObject {
    public let modules: EditorModules

    public init(modules: EditorModules = StandardModules()) {
        self.modules = modules
    }
}
