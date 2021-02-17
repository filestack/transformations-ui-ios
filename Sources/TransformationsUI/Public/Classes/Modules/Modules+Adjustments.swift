//
//  Modules+Adjustments.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 21/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

extension Modules {
    /// Adjustments module configuration object.
    public class Adjustments: NSObject, EditorModule {
        /// :nodoc:
        public let uuid = UUID()
        /// :nodoc:
        public var title = "Adjustments"
        /// :nodoc:
        public var icon: UIImage? = .fromBundle("icon-module-adjustments")
        /// :nodoc:
        public var isEnabled: Bool = true
        /// :nodoc:
        public let controllerType: EditorModuleController.Type = AdjustmentsController.self
        /// :nodoc:
        public let nodeCategory: RenderNodeCategory = .image
        /// :nodoc:
        public var nodeType: RenderGroupChildNode.Type? = AdjustmentsRenderNode.self
        /// :nodoc:
        public var autocreatesNode: Bool = true

        /// Commands available in `Filters` module.
        public var commands: [EditorModuleCommand] = [
            Commands.Blur(),
            Commands.Brightness(),
            Commands.Contrast(),
            Commands.Gamma(),
            Commands.HueRotation()
        ]

        /// All available commands.
        public class Commands: NSObject {
            /// Blur command.
            public class Blur: NSObject, EditorModuleCommand, BoundedRangeCommand {
                public let uuid = UUID()
                private(set) public lazy var title = "Blur"
                private(set) public lazy var icon: UIImage? = .fromBundle("icon-module-adjustments")

                public let defaultValue: Double = 0
                public let range: Range<Double> = (0..<0.125)
                public let format: BoundedRangeFormat = .percent

                public lazy var componentLabels: [String] = [title]
            }

            /// Brightness command.
            public class Brightness: NSObject, EditorModuleCommand, BoundedRangeCommand {
                public let uuid = UUID()
                private(set) public lazy var title = "Brightness"
                private(set) public lazy var icon: UIImage? = .fromBundle("icon-module-adjustments")

                public let defaultValue: Double = 0
                public let range: Range<Double> = (-1..<1)
                public let format: BoundedRangeFormat = .percent

                public lazy var componentLabels: [String] = [title]
            }

            /// Contrast command.
            public class Contrast: NSObject, EditorModuleCommand, BoundedRangeCommand {
                public let uuid = UUID()
                private(set) public lazy var title = "Contrast"
                private(set) public lazy var icon: UIImage? = .fromBundle("icon-module-adjustments")

                public let defaultValue: Double = 1
                public let range: Range<Double> = (0..<2)
                public let format: BoundedRangeFormat = .percent

                public lazy var componentLabels: [String] = [title]
            }

            /// Gamma command.
            public class Gamma: NSObject, EditorModuleCommand, BoundedRangeCommand {
                public let uuid = UUID()
                private(set) public lazy var title = "Gamma"
                private(set) public lazy var icon: UIImage? = .fromBundle("icon-module-adjustments")

                public let defaultValue: Double = 0
                public let range: Range<Double> = (-1..<1)
                public let format: BoundedRangeFormat = .percent

                public lazy var componentLabels: [String] = [
                    RGBComponent.red.description,
                    RGBComponent.green.description,
                    RGBComponent.blue.description
                ]
            }

            /// Hue Rotation command.
            public class HueRotation: NSObject, EditorModuleCommand, BoundedRangeCommand {
                public let uuid = UUID()
                private(set) public lazy var title = "Hue"
                private(set) public lazy var icon: UIImage? = .fromBundle("icon-module-adjustments")

                public let defaultValue: Double = 0
                public let range: Range<Double> = (-Double.pi..<Double.pi)
                public let format: BoundedRangeFormat = .degrees

                public lazy var componentLabels: [String] = [title]
            }
        }
    }
}
