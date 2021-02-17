//
//  Modules+Text.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 07/01/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import UIKit

extension Modules {
    /// Text module configuration object.
    public class Text: NSObject, EditorModule {
        /// :nodoc:
        public let uuid = UUID()
        /// :nodoc:
        public var title = "Text"
        /// :nodoc:
        public var icon: UIImage? = .fromBundle("icon-module-text")
        /// :nodoc:
        public var isEnabled: Bool = true
        /// :nodoc:
        public let controllerType: EditorModuleController.Type = TextController.self
        /// :nodoc:
        public let nodeCategory: RenderNodeCategory = .object
        /// :nodoc:
        public var nodeType: RenderGroupChildNode.Type? = TextRenderNode.self
        /// :nodoc:
        public var autocreatesNode: Bool = false

        /// Contains a list of available font families.
        public var availableFontFamilies: [String] = [
            "American Typewriter",
            "Arial",
            "Avenir",
            "Avenir Next",
            "Avenir Next Condensed",
            "Courier",
            "Courier New",
            "Futura",
            "Georgia",
            "Gill Sans",
            "Helvetica",
            "Helvetica Neue",
            "Menlo",
            "Times New Roman",
            "Verdana",
            "Zapfino"
        ]

        /// Default font family.
        public var defaultFontFamily: String = "Helvetica"

        /// Default font size.
        public var defaultFontSize: CGFloat = 24.0

        /// Default font color.
        public var defaultFontColor: UIColor = .white

        /// Default font style.
        public var defaultFontStyle: FontStyle = []

        /// Default text alignment.
        public var defaultTextAlignment: NSTextAlignment = .left

        /// Commands available in `Text` module.
        public var commandsInGroups: [[EditorModuleCommand]] = [
            [
                Commands.SelectFontFamily(),
                Commands.SelectFontColor(),
            ],
            [
                Commands.SelectFontStyle(),
                Commands.SelectTextAlignment()
            ]
        ]

        /// All available commands.
        public class Commands: NSObject {
            // Select Font Family
            public class SelectFontFamily: NSObject, EditorModuleCommand {
                public let uuid = UUID()
                private(set) public lazy var title = "Select Font Family"
            }

            // Select Font Color
            public class SelectFontColor: NSObject, EditorModuleCommand {
                public let uuid = UUID()
                private(set) public lazy var title = "Select Font Color"
            }

            // Select Font Style
            public class SelectFontStyle: NSObject, EditorModuleCommand {
                public let uuid = UUID()
                private(set) public lazy var title = "Select Font Style"
            }

            // Select Text Alignment
            public class SelectTextAlignment: NSObject, EditorModuleCommand {
                public let uuid = UUID()
                private(set) public lazy var title = "Select Text Alignment"
            }
        }
    }
}
