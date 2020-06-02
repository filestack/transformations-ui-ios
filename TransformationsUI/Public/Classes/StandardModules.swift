//
//  StandardModules.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 14/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

public class StandardModules: NSObject, EditorModules {
    public lazy var all: [EditorModule] = [transform]

    public var transform = Transform()
}

extension StandardModules {
    class Overview: NSObject, EditorModule {
        public var title: String = "Overview"
        public var icon: UIImage? = nil
        public var isEnabled: Bool = true

        public var viewController: EditorModuleVC

        init(using viewController: EditorModuleVC) {
            self.viewController = viewController
        }
    }
}
