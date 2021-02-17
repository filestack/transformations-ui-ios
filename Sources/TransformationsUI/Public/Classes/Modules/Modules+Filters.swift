//
//  Modules+Filters.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 20/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

extension Modules {
    /// Filters module configuration object.
    public class Filters: NSObject, EditorModule {
        /// :nodoc:
        public let uuid = UUID()
        /// :nodoc:
        public var title = "Filters"
        /// :nodoc:
        public var icon: UIImage? = .fromBundle("icon-module-filters")
        /// :nodoc:
        public var isEnabled: Bool = true
        /// :nodoc:
        public let controllerType: EditorModuleController.Type = FiltersController.self
        /// :nodoc:
        public let nodeCategory: RenderNodeCategory = .image
        /// :nodoc:
        public var nodeType: RenderGroupChildNode.Type? = FiltersRenderNode.self
        /// :nodoc:
        public var autocreatesNode: Bool = true

        /// Commands available in `Filters` module.
        public var commands: [EditorModuleCommand] = [
            Commands.Filter(type: .none),
            Commands.Filter(type: .chrome),
            Commands.Filter(type: .fade),
            Commands.Filter(type: .instant),
            Commands.Filter(type: .mono),
            Commands.Filter(type: .noir),
            Commands.Filter(type: .process),
            Commands.Filter(type: .tonal),
            Commands.Filter(type: .transfer)
        ]

        /// All available commands.
        public class Commands: NSObject {
            /// Filter command.
            public class Filter: NSObject, EditorModuleCommand {
                public let uuid = UUID()
                private(set) public lazy var title = type.title
                private(set) public lazy var icon: UIImage? = .fromBundle("icon-module-filters")

                @frozen public enum FilterType {
                    case none
                    case chrome
                    case fade
                    case instant
                    case mono
                    case noir
                    case process
                    case tonal
                    case transfer

                    var title: String {
                        switch self {
                        case .none:
                            return "None"
                        case .chrome:
                            return "Chrome"
                        case .fade:
                            return "Fade"
                        case .instant:
                            return "Instant"
                        case .mono:
                            return "Mono"
                        case .noir:
                            return "Noir"
                        case .process:
                            return "Process"
                        case .tonal:
                            return "Tonal"
                        case .transfer:
                            return "Transfer"
                        }
                    }
                }

                let type: FilterType

                public init(type: FilterType = .none) {
                    self.type = type
                }
            }
        }

    }
}
