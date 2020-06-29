//
//  File.swift
//  
//
//  Created by Ruben Nine on 25/06/2020.
//

import UIKit
import TransformationsUIShared

extension StandardModules {
    class Overview: NSObject, EditorModule {
        public var title: String = "Overview"
        public var isEnabled: Bool = true
        public let viewController: EditorModuleVC

        init(using viewController: EditorModuleVC) {
            self.viewController = viewController
        }
    }
}
