//
//  Modules+Stickers.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 14/12/20.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit

extension Modules {
    /// Stickers module configuration object.
    public class Stickers: NSObject, EditorModule {
        /// :nodoc:
        public let uuid = UUID()
        /// :nodoc:
        public var title = "Stickers"
        /// :nodoc:
        public var icon: UIImage? = .fromBundle("icon-module-stickers")
        /// :nodoc:
        public var isEnabled: Bool = true
        /// :nodoc:
        public let controllerType: EditorModuleController.Type = StickersController.self
        /// :nodoc:
        public let nodeCategory: RenderNodeCategory = .object
        /// :nodoc:
        public var nodeType: RenderGroupChildNode.Type? = StickersRenderNode.self
        /// :nodoc:
        public var autocreatesNode: Bool = false
        /// :nodoc:
        public var stickers: [String: [UIImage]] = [:]
    }
}
