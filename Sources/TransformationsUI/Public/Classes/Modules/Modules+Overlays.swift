//
//  Modules+Overlays.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 21/12/20.
//  Copyright © 2021 Filestack. All rights reserved.
//

import UIKit
import Filestack

extension Modules {
    /// Overlays module configuration object.
    public class Overlays: NSObject, EditorModule, RequiresFSClient {
        /// :nodoc:
        public let uuid = UUID()
        /// :nodoc:
        public var title = "Overlays"
        /// :nodoc:
        public var icon: UIImage? = .fromBundle("icon-module-overlays")
        /// :nodoc:
        public var isEnabled: Bool = true
        /// :nodoc:
        public let controllerType: EditorModuleController.Type = OverlaysController.self
        /// :nodoc:
        public let nodeCategory: RenderNodeCategory = .object
        /// :nodoc:
        public var nodeType: RenderGroupChildNode.Type? = OverlaysRenderNode.self
        /// :nodoc:
        public var autocreatesNode: Bool = false

        /// Filestack client
        public internal(set) var fsClient: Filestack.Client?
    }
}
