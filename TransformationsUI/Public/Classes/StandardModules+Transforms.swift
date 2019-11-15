//
//  StandardModules+Transforms.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 15/11/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

extension StandardModules {
    public class Transforms: NSObject, EditorModule {
        public var title: String = "Transforms"
        public var icon: UIImage = .fromFrameworkBundle("icon-module-transforms")
        public var isEnabled: Bool = true

        public lazy var viewController: EditorModuleVC = {
            return TransformsViewController(config: self)
        }()

        /// Commands available in `Transforms` module.
        public var commands: [EditorModuleCommand] = [
            Commands.Rotate(),
            Commands.Crop(type: .rect),
            Commands.Crop(type: .circle)
        ]

        /// All available commands.
        public class Commands: NSObject {
            /// Rotate command.
            public class Rotate: NSObject, EditorModuleCommand {
                public var title: String = "Rotate"
                public lazy var icon = UIImage.fromFrameworkBundle("icon-rotate")
            }

            /// Crop command.
            public class Crop: NSObject, EditorModuleCommand {
                public lazy var title: String = {
                    switch type {
                    case .rect:
                        return "Crop"
                    case .circle:
                        return "Circle"
                    }
                }()

                public lazy var icon: UIImage = {
                    switch type {
                    case .rect:
                        return .fromFrameworkBundle("icon-crop")
                    case .circle:
                        return .fromFrameworkBundle("icon-circle")
                    }
                }()

                /// Crop type.
                public enum CropType {
                    case rect
                    case circle
                }

                let type: CropType

                public init(type: CropType = .rect) {
                    self.type = type
                }
            }
        }
    }
}
