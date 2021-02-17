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
    public class Overlays: NSObject, EditorModule {
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
        /// App's URL scheme.
        public var callbackURLScheme: String = ""
        /// Filestack API key.
        public var filestackAPIKey: String = ""
        /// Filestack app secret.
        public var filestackAppSecret: String = ""
        /// Available Filestack picker cloud sources.
        public var availableCloudSources: [CloudSource] = CloudSource.all()
        /// Available Filestack picker local sources.
        public var availableLocalSources: [LocalSource] = LocalSource.all()
    }
}
