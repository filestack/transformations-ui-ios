//
//  StandardModules+Overview.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 25/06/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit
import TransformationsUIShared

extension StandardModules {
    class Overview: NSObject, EditorModule {
        public let uuid = UUID()
        public var title: String = "Overview"
        public var isEnabled: Bool = true
        public let controllerType: EditorModuleController.Type = OverviewController.self
        public let nodeCategory: RenderNodeCategory = .none
        public var nodeType: RenderGroupChildNode.Type? = nil
        public let modules: [EditorModule]
        public var autocreatesNode: Bool = false

        weak var pipeline: RenderPipeline?

        public init(modules: [EditorModule], pipeline: RenderPipeline) {
            self.modules = modules
            self.pipeline = pipeline
        }
    }
}
