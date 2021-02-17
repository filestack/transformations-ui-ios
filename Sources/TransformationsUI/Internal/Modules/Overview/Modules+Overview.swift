//
//  Modules+Overview.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 25/06/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit

extension Modules {
    class Overview: EditorModule {
        public let uuid = UUID()
        public var title: String = "Overview"
        public var isEnabled: Bool = true
        public let controllerType: EditorModuleController.Type = OverviewController.self
        public let nodeCategory: RenderNodeCategory = .none
        public var nodeType: RenderGroupChildNode.Type? = nil
        public let modules: [EditorModule]
        public var autocreatesNode: Bool = false

        weak var pipeline: RenderPipeline?

        let commands: [EditorModuleCommand] = [
            Commands.Edit(),
            Commands.Delete(),
            Commands.Reset(),
            Commands.Back(),
            Commands.Forward(),
            Commands.Flip(),
            Commands.Flop(),
            Commands.Opacity()
        ]

        init(modules: [EditorModule], pipeline: RenderPipeline) {
            self.modules = modules
            self.pipeline = pipeline
        }
    }
}

// MARK: - Commands

extension Modules.Overview {
    class Commands {
        class Edit: PointerHashable, EditorModuleCommand {
            /// :nodoc:
            public let uuid = UUID()
            /// :nodoc:
            public var title: String = "Edit"
            /// :nodoc:
            public lazy var icon: UIImage? = UIImage.fromBundle("icon-edit-object")
        }

        class Delete: PointerHashable, EditorModuleCommand {
            /// :nodoc:
            public let uuid = UUID()
            /// :nodoc:
            public var title: String = "Delete"
            /// :nodoc:
            public lazy var icon: UIImage? = UIImage.fromBundle("icon-delete-object")
        }

        class Reset: PointerHashable, EditorModuleCommand {
            /// :nodoc:
            public let uuid = UUID()
            /// :nodoc:
            public var title: String = "Reset"
            /// :nodoc:
            public lazy var icon: UIImage? = UIImage.fromBundle("icon-reset-transform-object")
        }

        class Back: PointerHashable, EditorModuleCommand {
            /// :nodoc:
            public let uuid = UUID()
            /// :nodoc:
            public var title: String = "Back"
            /// :nodoc:
            public lazy var icon: UIImage? = UIImage.fromBundle("icon-send-back-object")
        }

        class Forward: PointerHashable, EditorModuleCommand {
            /// :nodoc:
            public let uuid = UUID()
            /// :nodoc:
            public var title: String = "Forward"
            /// :nodoc:
            public lazy var icon: UIImage? = UIImage.fromBundle("icon-send-forward-object")
        }

        class Flip: PointerHashable, EditorModuleCommand {
            /// :nodoc:
            public let uuid = UUID()
            /// :nodoc:
            public var title: String = "Flip"
            /// :nodoc:
            public lazy var icon: UIImage? = UIImage.fromBundle("icon-flip-object")
        }

        class Flop: PointerHashable, EditorModuleCommand {
            /// :nodoc:
            public let uuid = UUID()
            /// :nodoc:
            public var title: String = "Flop"
            /// :nodoc:
            public lazy var icon: UIImage? = UIImage.fromBundle("icon-flop-object")
        }

        class Opacity: PointerHashable, EditorModuleCommand, BoundedRangeCommand {
            /// :nodoc:
            public let uuid = UUID()
            /// :nodoc:
            public let title = "Opacity"
            /// :nodoc:
            public lazy var icon: UIImage? = UIImage.fromBundle("icon-opacity-object")
            /// :nodoc:
            public let defaultValue: Double = 0
            /// :nodoc:
            public let range: Range<Double> = (0..<1)
            /// :nodoc:
            public let format: BoundedRangeFormat = .percent
            /// :nodoc:
            public lazy var componentLabels: [String] = [title]
        }
    }
}
