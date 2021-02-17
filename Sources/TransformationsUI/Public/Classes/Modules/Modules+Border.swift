//
//  Modules+Border.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 10/08/2020.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

extension Modules {
    /// Border module configuration object.
    public class Border: NSObject, EditorModule {
        /// :nodoc:
        public let uuid = UUID()
        /// :nodoc:
        public var title = "Border"
        /// :nodoc:
        public var icon: UIImage? = .fromBundle("icon-module-border")
        /// :nodoc:
        public var isEnabled: Bool = true
        /// :nodoc:
        public let controllerType: EditorModuleController.Type = BorderController.self
        /// :nodoc:
        public let nodeCategory: RenderNodeCategory = .overlay
        /// :nodoc:
        public var nodeType: RenderGroupChildNode.Type? = BorderRenderNode.self
        /// :nodoc:
        public var autocreatesNode: Bool = true

        /// Commands available in `Border` module.
        public var commands: [EditorModuleCommand] = [
            Commands.Width(),
            Commands.Color(),
            Commands.Opacity(),
        ]

        public var defaultColor: UIColor = .white

        /// All available commands.
        public class Commands: NSObject {
            /// Width command.
            public class Width: NSObject, EditorModuleCommand, BoundedRangeCommand {
                public let uuid = UUID()
                private(set) public lazy var title = "Width"

                public let defaultValue: Double = 0
                public let range: Range<Double> = (0..<0.25)
                public let format: BoundedRangeFormat = .percent

                public lazy var componentLabels: [String] = [title]
            }

            /// Opacity command.
            public class Opacity: NSObject, EditorModuleCommand, BoundedRangeCommand {
                public let uuid = UUID()
                private(set) public lazy var title = "Opacity"

                public let defaultValue: Double = 0
                public let range: Range<Double> = (0..<1)
                public let format: BoundedRangeFormat = .percent

                public lazy var componentLabels: [String] = [title]
            }

            /// Color command.
            public class Color: NSObject, EditorModuleCommand {
                public let uuid = UUID()
                private(set) public lazy var title = "Color"
            }
        }
    }
}
